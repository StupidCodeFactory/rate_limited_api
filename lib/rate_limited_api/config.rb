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
      @redis = "redis://localhost:6379"
    end
  end
end
