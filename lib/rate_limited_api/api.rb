module RateLimitedApi
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
end
