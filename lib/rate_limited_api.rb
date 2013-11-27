require "rate_limited_api/version"
require "rate_limited_api/api"
require "rate_limited_api/limiter"
require "active_support/core_ext"
require "resque_scheduler"
require "redis"

module RateLimitedApi
  class << self
    attr_accessor :configuration
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :redis

    def initialize
      @redis = Redis.new(host: 'localhost', port: 6379)
    end
  end

end
