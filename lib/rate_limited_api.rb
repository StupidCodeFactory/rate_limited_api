require 'rate_limited_api/api'
require 'rate_limited_api/limiter'
require 'active_support'
require 'active_support/core_ext/numeric'

require 'redis'

module RateLimitedApi
  class << self
    attr_accessor :configuration

    @@limiters = {}

    def register(limiter, rate, limite)
      @@limiters[limiter] = Limiter.new(limiter, rate, limite)
    end

    def [](limiter)
      @@limiters[limiter]
    end

    def limiters
      @@limiters
    end

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
