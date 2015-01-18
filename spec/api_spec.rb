require 'spec_helper'
require 'net/http'

class ExternalRateLimitedApi
  include RateLimitedApi::DSL
  attr_reader :proc

  def initialize
    @proc = Proc.new { 1 + 1 }
  end
end


RSpec.describe RateLimitedApi::DSL do
  let(:service_object)  { ExternalRateLimitedApi.new }

  before do

    RateLimitedApi.register :foo, 10, :seconds
    RateLimitedApi.register :baz, 5, :seconds

    def service_object.foo_no_block
      with_limiter :foo
    end

    def service_object.unregistered_limiter
      with_limiter :bar do
        # never executed
      end
    end

    def service_object.registered_limiter
      with_limiter :foo, &proc
    end

    def service_object.chained_registered_limiter
      with_limiter :foo do
        with_limiter(:baz, &proc)
      end
    end

  end

  describe '#with_limiter' do

    it 'must be called with a block' do
      expect { service_object.foo_no_block }.to raise_error(
        ArgumentError, 'RateLimitedApi::DSL#with_limiter must be called with a block')
    end

    it 'must be called with a registered limiter' do
      expect { service_object.unregistered_limiter }.to raise_error(
        ArgumentError, "Unknown limiter 'bar'")
    end

    it 'calls the registered limiter with the given block' do
      expect(RateLimitedApi[:foo]).to receive(:limit).and_yield
      expect(service_object.proc).to  receive(:call)
      service_object.registered_limiter
    end

    describe 'with chained limiters' do

      it 'calls all of the limiters' do
        expect(RateLimitedApi[:foo]).to receive(:limit).and_yield
        expect(RateLimitedApi[:baz]).to receive(:limit).and_yield
        expect(service_object.proc).to  receive(:call)

        service_object.chained_registered_limiter
      end

    end

    describe 'When the limit has been reached' do

      it 'schedules the a job' do
        expect(RateLimitedApi[:foo]).to receive(:schedule).and_yield
        11.times { service_object.registered_limiter }
      end

    end

  end

  describe 'with an external API' do

    before do

      def service_object.api_calls(seconds_to_wait = 2)
        responses = []
        with_limiter :foo do
          3.times do |i|
            responses << Net::HTTP.get(URI("http://localhost:#{Mimic::MIMIC_DEFAULT_PORT}/pong"))
            sleep seconds_to_wait
          end
        end
        responses
      end


      Mimic.mimic(log: STDOUT) do
        use Rack::Throttle::Interval, min: 2
        get('/pong') do
          [200, {}, 'pong']
        end
      end

    end

    it 'allows all requests' do
      expect(service_object.api_calls).to eq(['pong'] * 3)
    end

    describe 'when exceeding allowed requests' do

      it 'only perform the possible request and returns 403 for other requests' do
        expect(service_object.api_calls(1)).to eq([
            "pong", "403 Forbidden (Rate Limit Exceeded)\n", "403 Forbidden (Rate Limit Exceeded)\n"])
      end

    end

  end
end
