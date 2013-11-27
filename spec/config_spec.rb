require 'spec_helper'

describe "Configuration" do
  it "has a sensible default redis configuration" do
    RateLimitedApi.configuration.redis.should == { host: 'localhost', port: 6379 }
  end

  it "enables configuration on of the redis server" do
    RateLimitedApi.configure do |config|
      config.redis = { host: 'redis.example.com', port: 666 }
    end
    RateLimitedApi.configuration.redis.should == { host: 'redis.example.com', port: 666 }
  end
end
