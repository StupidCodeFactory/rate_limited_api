module RateLimitedApi

  class RateLimitReached < StandardError; end

  class Limiter

    def initialize(api_id, rate, time_unit)
      @api_id    = api_id
      @rate      = rate
      @time_unit = time_unit
      if redis.exists(started_at_key)
        @start   = Time.at(Integer(redis.get(started_at_key)))
      end

    end

    def incr
      raise RateLimitReached if has_reached_limit?

      if set_expiry?
        s = start!
        redis.multi do
          redis.rpush api_id, api_id
          set_expiry s
        end
      else
        redis.rpushx api_id, api_id
      end
    end

    def ends_at
      @start + duration
    end

    def expires_in
      now = Time.now
      if ends_at <= now
        0
      else
        (ends_at - now).to_i
      end
    end

    private

    def duration
      1.send(@time_unit)
    end

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

    def set_expiry s
      redis.expire api_id, s.to_i + duration
      redis.expire started_at_key, s.to_i + duration
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
