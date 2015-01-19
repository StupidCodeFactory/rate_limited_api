[![Build Status](https://travis-ci.org/StupidCodeFactory/rate_limited_api.svg)](https://travis-ci.org/StupidCodeFactory/rate_limited_api)
![Dependency Status](https://gemnasium.com/StupidCodeFactory/rate_limited_api.svg)](https://gemnasium.com/StupidCodeFactory/rate_limited_api)
#### RateLimitedApi ####

This library aims at managing rate limitation of APIs accross multiple
server/application

It currently depends on redis

## Installation

```shell
    gem 'rate_limited_api', github: 'StupidCodeFactory/rate_limited_api'
```
And then execute:

    $ bundle

## Usage

### configuration
```ruby
    RateLimitedApi.configure do |config|
      config.redis = "redis://redis.example.com:666"
    end
```

### use with any object
```ruby
    rate_limiter = RateLimitedApi::Limiter.new :facebook, 150, :day
    graph = Koala::Facebook::API.new(oauth_access_token)
    facebook = RateLimitedApi::Api.new(graph, [:get_object, :get_connections], rate_limiter)
    100.times { facebook.get_object('me') }     # => '{'id': 123123234}'
    50.times { facebook.get_connections('me', 'friends') } # => '{'friends': [{'id': 4564564}]}'

    facebook.get_object('me') # ooops raises RateLimitedApi::RateLimitReached !
```
### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
