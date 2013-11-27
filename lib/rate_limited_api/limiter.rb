module RateLimitedApi

  class RateLimitReached < StandardError; end

  class Limiter

    def initialize(api_id, rate, time_unit)
      @api_id    = api_id
      @rate      = rate
      @time_unit = time_unit
    end

    def incr
      raise RateLimitReached if has_reached_limit?
      redis.multi do
        set_expiry if set_expiry?
        redis.incr api_id
      end
    end

    private

    def set_expiry?
      api_count == 0
    end

    def set_expiry
      redis.expire api_id, expires_in
    end

    def has_reached_limit?
      Integer(api_count) >= rate
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
