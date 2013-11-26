require 'spec_helper'

describe RateLimitedApi::Api do
  let(:service_object)  { ExternalRateLimitedApi.new }
  let(:limiter)         { RateLimitedApi::Limiter.new(:foo, 150, :second) }
  let(:limited_methods) { [:get_user, :post_message] }
  let(:api)             { RateLimitedApi::Api.new(service_object, limited_methods, limiter) }
  let(:mock_redis)      { double(Redis) }
  let(:nowish)          { Time.now }

  context "When the rate limit hasn't been reached" do
    before do
      Redis.should_receive(:new).with(RateLimitedApi.configuration.redis).and_return(mock_redis)
      Time.stub(:now).and_return(nowish)
      mock_redis.should_receive(:get).exactly(4).times.with(:foo).and_return(15)
      mock_redis.should_receive(:incr).exactly(2).times.with(:foo)
    end

    it "allows limited methods to be called" do
      api.get_user.should     == "Here is your user"
      api.post_message.should ==  "Message posted!"
    end

  end

  describe "When the rate limit has been reached" do
    before do
      Redis.should_receive(:new).with(RateLimitedApi.configuration.redis).and_return(mock_redis)
      Time.stub(:now).and_return(nowish)
    end

    it "should raise an RateLimitedApi::RateLimitReached" do
      mock_redis.should_receive(:get).times.with(:foo).and_return(150)
      expect { api.get_user }.to raise_exception(RateLimitedApi::RateLimitReached)
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
