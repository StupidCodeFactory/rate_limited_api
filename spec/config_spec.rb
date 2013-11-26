require 'spec_helper'

describe "Configuration" do
  it "has a sensible default redis configuration" do
    RateLimitedApi.configuration.redis.should == "redis://localhost:6379"
  end

  it "enables configuration on of the redis server" do
    RateLimitedApi.configure do |config|
      config.redis = "redis://redis.example.com:666"
    end
    RateLimitedApi.configuration.redis.should == "redis://redis.example.com:666"
  end
end
