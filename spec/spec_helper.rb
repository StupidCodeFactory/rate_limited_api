require 'rspec'
require 'rate_limited_api'

RSpec.configure do |c|
  c.mock_with :rspec
end

class ExternalRateLimitedApi
  def get_user; "Here is your user" end

  def post_message;  "Message posted!" end

  def unlimited_method_call; end
end

