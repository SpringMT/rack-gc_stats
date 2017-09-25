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
      scoreboard_path  = options[:scoreboard_path]
      if scoreboard_path
        @scoreboard = WorkerScoreboard.new(scoreboard_path)
      end
    end

    def call(env)
      # Return GC stats
      if env['PATH_INFO'] == @path
        unless allowed?(env['REMOTE_ADDR'])
          return [403, {'Content-Type' => 'text/plain'}, [ 'Forbidden' ]]
        end

        body = ''
        status = {}

        if @scoreboard
          stats = @scoreboard.read_all
          all_workers = stats.keys
          if !@skip_ps_command && RUBY_PLATFORM !~ /mswin(?!ce)|mingw|cygwin|bccwin/
            parent_pid = Process.ppid
            ps = `LC_ALL=C command ps -e -o ppid,pid`
            ps.each_line do |line|
              line.lstrip!
              next if line =~ /^\D/
              ppid, pid = line.chomp.split(/\s+/, 2)
              all_workers << pid.to_i if ppid.to_i == parent_pid
            end
          end
          process_gc_stats_list = []
          all_workers.each do |pid|
            json = stats[pid] || '{}'
            gc_status = JSON.parse(json, symbolize_names: true) rescue {}
            gc_status[:pid] ||= pid
            body << sprintf("%s\n", gc_status.to_s)
            process_gc_stats_list << gc_status
          end
          body.chomp!
          status[:stats] = process_gc_stats_list
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
      return unless @scoreboard
      gc_result = GC.stat
      gc_result[:pid] = Process.pid
      gc_result[:ppid] = Process.ppid
      gc_result[:time] = Time.now.to_i
      gc_result[:uptime] = @uptime
    end

  end
end
