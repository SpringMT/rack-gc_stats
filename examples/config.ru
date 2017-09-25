$:.unshift File.join(File.dirname(__FILE__), '..',  'lib/')
require 'rack/gc_stats'

use Rack::GCStats, scoreboard_path: './tmp', enabled: true

class HelloWorldApp
  def call(env)
    [ 200, { 'Content-Type' => 'text/plain' }, ['Hello World!'] ]
  end
end

map "/foo" do
  run HelloWorldApp.new
end
