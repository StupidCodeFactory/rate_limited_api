require 'spec_helper'

describe "Configuration" do
  it "has a sensible default redis configuration" do
    expect(RateLimitedApi.configuration.redis.client.host).to eq('localhost')
    expect(RateLimitedApi.configuration.redis.client.port).to eq(6379)
  end

  it "enables configuration on of the redis server" do
    RateLimitedApi.configure do |config|
      config.redis = Redis.new(host: 'redis.example.com', port: 666)
    end
    RateLimitedApi.configuration.redis.client.host == 'redis.example.com'
    RateLimitedApi.configuration.redis.client.port == 6379

    # reset redis connection to localhost
    RateLimitedApi.configure do |config|
      config.redis = Redis.new(host: 'localhost', port: 6379)
    end
  end

end
