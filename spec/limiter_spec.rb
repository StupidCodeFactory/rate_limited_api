require 'spec_helper'

describe RateLimitedApi::Limiter do
  let(:limiter) { RateLimitedApi::Limiter.new(:foo, 10, :day) }
  let(:r) { RateLimitedApi.configuration.redis }

  describe "#incr" do
    let!(:nowish)     { Time.now }

    before do
      Time.stub(:now).and_return(nowish)
    end

    context "When the rate limit hasn't been reached" do

      context "When it's the first api call" do
        it "sets the expirey of the key" do
          r.should_receive(:expire).with(:foo, nowish.to_i + 1.day.to_i)
          limiter.incr
        end

      end

      context "When it's not the first api call" do
        before do
          limiter.incr
        end

        it "does not set the expiry time" do
          r.should_not_receive(:expire)
          limiter.incr
        end

        it "the counter is incremented" do
          expect {
            limiter.incr
          }.to change { r.llen(:foo) }.by(1)

        end
      end

    end

    context "When the rate limit has been reached" do
      before do
        10.times { limiter.incr }
      end

      it "the counter is not incremented and raises a RateLimitReached exception" do
        r.should_not_receive(:incr)
        expect {
          limiter.incr
        }.to raise_exception(RateLimitedApi::RateLimitReached)
      end

    end
  end
end
