module RateLimitedApi

  class RateLimitReached < StandardError; end

  class Limiter

    def initialize(api_id, rate, time_unit)
      @api_id    = api_id
      @rate      = rate
      @time_unit = time_unit
    end

    def incr
      redis.multi do
        raise RateLimitReached if has_reached_limit?

        set_expiry if set_expiry?
        redis.incr api_id
      end
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
