require 'rack/gc_stats/version'
require 'json'
require 'worker_scoreboard'

module Rack
  class GCStats
    def initialize(app, options = {})
      @app = app
      @uptime = Time.now.to_i
      @skip_ps_command = options[:skip_ps_command] || false
      @allow = options[:allow] || []
      @path = options[:path] || '/gc_stats'
      @enabled = options[:enabled] || false
      scoreboard_path  = options[:scoreboard_path]
      if scoreboard_path
        @scoreboard = WorkerScoreboard.new(scoreboard_path)
      end
    end

    def call(env)
      # Return GC stats
      if env['PATH_INFO'] == @path
        update_gc_stat

        unless allowed?(env['REMOTE_ADDR'])
          return [403, {'Content-Type' => 'text/plain'}, [ 'Forbidden' ]]
        end

        body = ''
        status = {}

        if @scoreboard
          stats = @scoreboard.read_all
          all_worker_pids = if !@skip_ps_command && RUBY_PLATFORM !~ /mswin(?!ce)|mingw|cygwin|bccwin/
                              worker_pids_from_ps_command
                            else
                              stats.keys
                            end
          process_gc_stats_list = []
          total_gc_count = 0
          total_minor_gc_count = 0
          total_major_gc_count = 0

          all_worker_pids.each do |pid|
            json = stats[pid] || '{}'
            gc_status = JSON.parse(json, symbolize_names: true) rescue {}
            gc_status[:pid] ||= pid
            body << sprintf("%s\n", gc_status.to_s)
            total_gc_count += gc_status[:count] || 0
            total_minor_gc_count += gc_status[:minor_gc_count] || 0
            total_major_gc_count += gc_status[:major_gc_count] || 0
            process_gc_stats_list << gc_status
          end
          body.chomp!
          status[:stats] = process_gc_stats_list
          status[:total_gc_count] = total_gc_count
          status[:total_minor_gc_count] = total_minor_gc_count
          status[:total_major_gc_count] = total_major_gc_count
        else
          body << "WARN: Scoreboard has been disabled\n"
          status[:WARN] = 'Scoreboard has been disabled'
        end

        if (env['QUERY_STRING'] || '') =~ /\bjson\b/
          return [200, {'Content-Type' => 'application/json; charset=utf-8'}, [status.to_json]]
        end
        return [200, {'Content-Type' => 'text/plain'}, [body]]
      end

      res = @app.call(env)
      update_gc_stat
      res
    end

    private

    def allowed?(address)
      return true if @allow.empty?
      @allow.include?(address)
    end

    def update_gc_stat
      return unless @enabled
      return unless @scoreboard
      gc_result = GC.stat
      gc_result[:pid] = Process.pid
      gc_result[:ppid] = Process.ppid
      gc_result[:time] = Time.now.to_i
      gc_result[:uptime] = @uptime
      @scoreboard.update(gc_result.to_json)
    end

    def worker_pids_from_ps_command
      parent_pid = Process.ppid
      all_worker_pids = []
      ps = `LC_ALL=C command ps -e -o ppid,pid`
      ps.each_line do |line|
        line.lstrip!
        next if line =~ /^\D/
        ppid, pid = line.chomp.split(/\s+/, 2)
        all_worker_pids << pid.to_i if ppid.to_i == parent_pid
      end
      all_worker_pids
    end
  end
end
