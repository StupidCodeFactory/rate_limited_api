require 'spec_helper'

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

  end

  describe '#with_limiter' do

    it 'must be called with a block' do
      expect { service_object.foo_no_block }.to raise_error(
        ArgumentError, 'RateLimitedApi::DSL#with_limiter must be called with a block')
    end

    it 'must be called woth a registered limiter' do
      expect { service_object.unregistered_limiter }.to raise_error(
        ArgumentError, "Unknown limiter 'bar'")
    end

    it 'calls the registered limiter with the given block' do
      expect(RateLimitedApi[:foo]).to receive(:limit).and_yield
      expect(service_object.proc).to  receive(:call)
      service_object.registered_limiter
    end
  end
end


RSpec.describe RateLimitedApi::Api do

  let(:limiter)         { RateLimitedApi::Limiter.new(:foo, 10, :day) }
  let(:limited_methods) { [:get_user, :post_message, :post_comment] }
  let(:retry_klass)     { nil }
  let(:api)             { RateLimitedApi::Api.new(service_object, limited_methods, limiter, retry_klass) }
  let(:r) { RateLimitedApi.configuration.redis }
  let!(:nowish)          { Time.now }


  context "When the rate limit hasn't been reached" do
    before do
      Time.stub(:now).and_return(nowish)
    end

    it "allows limited methods to be called" do
      api.get_user.should     == "Here is your user"
      api.post_message.should ==  "Message posted!"
    end

  end

  describe "When the rate limit has been reached" do
    before do
      10.times { limiter.incr }
    end

    it "should raise an RateLimitedApi::RateLimitReached" do
      expect { api.get_user }.to raise_exception(RateLimitedApi::RateLimitReached)
    end

    describe "Retrying a call" do
      let(:retry_klass) { RetryApiCall }
      it "sechdules a jobs to execute failed calls" do
        expect { api.post_comment("trolling") }.not_to raise_error
        RetryApiCall.should have_scheduled(:post_comment, ["trolling"])
      end
    end
  end

  describe "#method_missing" do
    it "responds to public api of the wrapped object" do
      api.should respond_to(:get_user)
      api.should respond_to(:post_message)
      api.should respond_to(:unlimited_method_call)
    end

    it "does not respond to private methods of the wrapped object" do
      api.should_not respond_to(:private_stuff)
    end
  end

end
