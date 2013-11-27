require 'spec_helper'

describe RateLimitedApi::Limiter do
  let(:limiter) { RateLimitedApi::Limiter.new(:foo, 1500, :day) }

  describe "#incr" do
    let(:mock_redis) { double(Redis) }
    let!(:nowish)     { Time.now }

    before do
      Redis.should_receive(:new).with(RateLimitedApi.configuration.redis).and_return(mock_redis)
      Time.stub(:now).and_return(nowish)
    end

    context "When the rate limit hasn't been reached" do

      before do
        mock_redis.should_receive(:multi).and_yield
      end

      context "When it's the first api call" do

        it "sets the expirey of the key" do
          mock_redis.should_receive(:get).with(:foo).twice.and_return(0)
          mock_redis.should_receive(:expire).with(:foo, nowish.to_i + 1.day.to_i)
          mock_redis.should_receive(:incr).with(:foo)
          limiter.incr
        end

      end

      context "When it's not the first api call" do

        before do
          mock_redis.should_receive(:get).with(:foo).twice.and_return(500)
          mock_redis.should_receive(:incr).with(:foo)
        end

        it "does not set the expiry time" do
          mock_redis.should_not_receive(:expire)
          limiter.incr
        end

        it "the counter is incremented" do
          limiter.incr
        end
      end

    end

    context "When the rate limit has been reached" do
      before do
        mock_redis.should_receive(:get).with(:foo).and_return(1500)
      end

      it "the counter is not incremented and raises a RateLimitReached exception" do
        mock_redis.should_not_receive(:incr)
        expect {
          limiter.incr
        }.to raise_exception(RateLimitedApi::RateLimitReached)
      end

    end
  end
end
