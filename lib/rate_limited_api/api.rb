module RateLimitedApi
  module DSL

    def with_limiter limiter_id, args = [], retry_klass = nil, &block
      raise ArgumentError.new 'RateLimitedApi::DSL#with_limiter must be called with a block' unless block_given?

      limiter = RateLimitedApi[limiter_id]

      raise ArgumentError.new "Unknown limiter '#{limiter_id}'" if limiter.nil?

      if !limiter.has_reached_limit?
        limiter.limit(args, &block)
      elsif !retry_klass.nil?
        limiter.schedule(retry_klass, args)
      end
    end
  end
end
