#### RateLimitedApi ####

This library aims at managing rate limitation of APIs accross multiple
server/application

## Installation

```shell
    gem 'rate_limited_api', github: 'StupidCodeFactory/rate_limited_api'
```
And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rate_limited_api

## Usage

```ruby
    rate_limiter = RateLimitedApi::Limiter.new :facebook, 150, :day
    graph = Koala::Facebook::API.new(oauth_access_token)
    facebook = RateLimitedApi::Api.new(graph, [:get_object, :get_connections], rate_limiter)
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
