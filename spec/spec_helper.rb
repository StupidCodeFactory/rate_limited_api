require 'bundler/setup'

Bundler.setup

require 'rspec'
require 'rate_limited_api'
require 'resque_spec/scheduler'

RSpec.configure do |c|
  c.mock_with :rspec
  c.before do
    RateLimitedApi.configuration.redis.flushall

  end
end

class ExternalRateLimitedApi
  def get_user; "Here is your user" end

  def post_message;  "Message posted!" end

  def post_comment(comment); end

  def unlimited_method_call; end

  private
  def private_stuff; end
end

class RetryApiCall
  @queue = :retry_api_call

  def self.perform(*args)
    puts MutliJson.load(args).inspect
  end
end
