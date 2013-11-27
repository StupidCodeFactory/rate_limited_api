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

      if set_expiry?
        start!
        redis.multi do
          redis.rpush api_id, api_id
          set_expiry
        end
      else
        redis.rpushx api_id, api_id
      end
    end

    def expires_in
      return unless @start
      @expires_in ||= (@start + 1.send(@time_unit)).to_i
    end

    private

    def start!
      @start ||= begin
        s = Time.now
        redis.set(started_at_key, s.to_i)
        s
      end
    end

    def set_expiry?
      !redis.exists(api_id)
    end

    def set_expiry
      redis.expire api_id, expires_in
    end

    def has_reached_limit?
      Integer(api_count) >= rate
    end

    def api_count
      redis.llen(api_id) || 0
    end

    def redis
      @redis ||= RateLimitedApi.configuration.redis
    end

    def started_at_key
      "#{api_id}_started_at"
    end

    def api_id
      @api_id
    end

    def rate
      @rate
    end
  end
end
