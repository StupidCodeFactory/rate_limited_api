module RateLimitedApi

  class RateLimitReached < StandardError; end

  class Api
    def initialize(object, limited_methods, limiter)
      @object          = object
      @limited_methods = limited_methods.map(&:to_sym)
      @limiter         = limiter
    end

    def method_missing(method_name, *args)
      if @object.respond_to?(method_name)
        @limiter.incr if @limited_methods.include?(method_name.to_sym)
        @object.send(method_name, *args)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @object.respond_to?(method_name) || super
    end
  end

  class Limiter

    def initialize(api_id, rate, time_unit)
      @api_id    = api_id
      @rate      = rate
      @time_unit = time_unit
    end

    def incr
      raise RateLimitReached if has_reached_limit?

      set_expiry if set_expiry?
      redis.incr api_id
    end

    private

    def set_expiry?
      api_count == 0
    end

    def set_expiry
      redis.expire expires_in
    end

    def has_reached_limit?
       api_count >= rate
    end

    def api_count
      redis.get(api_id) || 0
    end

    def redis
      @redis ||= Redis.new(RateLimitedApi.configuration.redis)
    end

    def expires_in
      (Time.now + 1.send(@time_unit)).to_i
    end

    def api_id
      @api_id
    end

    def rate
      @rate
    end
  end
end
