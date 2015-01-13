module RateLimitedApi
  module DSL

    def with_limiter limiter_id, &block
      raise ArgumentError.new 'RateLimitedApi::DSL#with_limiter must be called with a block' unless block_given?

      limiter = RateLimitedApi[limiter_id]

      raise ArgumentError.new "Unknown limiter '#{limiter_id}'" if limiter.nil?

      limiter.limit(&block)
    end
  end
end














module RateLimitedApi
  class Api
    def initialize(object, limited_methods, limiter, retry_klass)
      @object          = object
      @limited_methods = limited_methods.map(&:to_sym)
      @limiter         = limiter
      @retry_klass     = retry_klass
    end

    def method_missing(method_name, *args)
      if @object.respond_to?(method_name)

        if !@retry_klass
          @limiter.incr if @limited_methods.include?(method_name.to_sym)
          @object.send(method_name, *args)
        else
          begin
            @limiter.incr if @limited_methods.include?(method_name.to_sym)
          rescue RateLimitReached
            Resque.enqueue_in(@limiter.expires_in, @retry_klass, method_name, args)
          end
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @object.respond_to?(method_name) || super
    end
  end

end
