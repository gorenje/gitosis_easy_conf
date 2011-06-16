module Gitosis
  extend self

  class Config
    def initialize(&block)
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0 || block_given?
        (@configs ||= {})[method.to_sym] = case method
                                           when :fork_naming_convention then
                                             block
                                           when :filename then
                                             args.first
                                           else
                                             [args, block]
                                           end
      else
        @configs[method]
      end
    end
  end

  def config(&block)
    block_given? ? @@config = Config.new(&block) : @@config
  end
end
