require 'spec_helper'
require 'rack'

RSpec.describe Rack::GCStats do
  app = lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
  }

  context 'confirm to Rack::Lint' do
    context 'Not affected WorkerScoreboard' do
      subject do
        Rack::Lint.new(Rack::GCStats.new(app))
      end
      it do
        response = Rack::MockRequest.new(subject).get('/')
        expect(response.body).to eq 'Hello, World!'
      end
    end
    context 'Affected WorkerScoreboard' do
      subject do
        Rack::Lint.new(Rack::GCStats.new(app, scoreboard_path: Dir.tmpdir))
      end
      it do
        response = Rack::MockRequest.new(subject).get('/')
        expect(response.body).to eq 'Hello, World!'
      end
    end
  end

  context 'return valid gc stats with text' do
    subject do
      Rack::Lint.new(Rack::GCStats.new(app, scoreboard_path: Dir.tmpdir, enable: true))
    end
    it do
      response = Rack::MockRequest.new(subject).get('/gc_stats')
      expect(response.successful?).to be_truthy
      expect(response.headers['Content-Type']).to eq 'text/plain'
    end
  end

  context 'return json but not enabled' do
    subject do
      Rack::Lint.new(Rack::GCStats.new(app, scoreboard_path: Dir.tmpdir))
    end
    it do
      Rack::MockRequest.new(subject).get('/')
      response = Rack::MockRequest.new(subject).get('/gc_stats?json')
      expect(response.successful?).to be_truthy
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(JSON.parse(response.body)['stats'].first.keys).to eq(['pid'])
    end
  end

  context 'return json with enabled' do
    subject do
      Rack::Lint.new(Rack::GCStats.new(app, scoreboard_path: Dir.tmpdir, enabled: true))
    end
    it do
      response = Rack::MockRequest.new(subject).get('/gc_stats?json')
      expect(response.successful?).to be_truthy
      expect(response.headers['Content-Type']).to eq 'application/json; charset=utf-8'
      expect(JSON.parse(response.body)['stats'].first.keys).to include('pid', 'minor_gc_count', 'major_gc_count')
    end
  end

end
