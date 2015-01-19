require 'spec_helper'

RSpec.describe RateLimitedApi::Limiter do

  let(:limiter) { RateLimitedApi::Limiter.new(:foo, 10, :day) }
  let(:r)       { Redis.new(url: 'redis://localhost:6379/10') }
  let(:start_key) { 'foo_started_at' }

  before do
    expect(RateLimitedApi.configuration).to receive(:redis).and_return(r)
  end

  describe "#incr" do
    let!(:nowish)  { Time.now.to_i }

    before do
      allow(Time).to receive(:now).and_return(nowish)
      expect(r).to receive(:set).with(start_key, nowish)
    end

    context "When the rate limit hasn't been reached" do

      context "When it's the first api call" do

        it 'sets the start time key and expiry of the key' do
          expect(r).to receive(:expire).with(:foo,      nowish + 1.day)
          expect(r).to receive(:expire).with(start_key, nowish + 1.day)
          limiter.incr
        end
      end

      context "When it's not the first api call" do
        before do
          limiter.incr
        end

        it "does not set the expiry time" do
          expect(r).to_not receive(:expire).with(:foo,      nowish + 1.day)
          expect(r).to_not receive(:expire).with(start_key, nowish + 1.day)

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

      describe '#has_reached_limit?' do
        it "is true" do
          expect(limiter.has_reached_limit?).to be true
        end
      end

    end
  end
end
