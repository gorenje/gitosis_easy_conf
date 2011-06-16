module Gitosis
  extend self

  class Config
    def initialize(&block)
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0 || block_given?
        (@configs ||= {})[method.to_sym] = [args, block]
      else
        @configs[method]
      end
    end
  end

  def config(&block)
    block_given? ? @@config = Config.new(&block) : @@config
  end
end
