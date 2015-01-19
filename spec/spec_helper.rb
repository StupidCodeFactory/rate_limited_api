require 'bundler/setup'

Bundler.setup :default

require 'rspec'
require 'rate_limited_api'
require 'database_cleaner'
require 'mimic'
require 'rack/throttle'

require 'byebug' rescue LoadError

RSpec.configure do |c|
  c.mock_with :rspec

  c.before(:suite) do
    DatabaseCleaner[:redis, url: 'redis://localhost:6379/10']
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  c.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  c.before do
    RateLimitedApi.configuration.redis.flushall
  end
end


class RetryApiCall
  @queue = :retry_api_call

  def self.perform(*args)
    puts MutliJson.load(args).inspect
  end
end
