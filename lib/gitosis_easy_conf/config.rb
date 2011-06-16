module Gitosis
  extend self

  class Config
    def initialize(&block)
      @configs = {}
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0 || block_given?
        @configs[method] = case method
                           when :fork_naming_convention then
                             if block_given? && block.arity != 2
                               raise ArgumentError,"Block needs to take 2 arguments"
                             end
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
    block_given? ? @@config = Config.new(&block) : (@@config ||= nil)
  end
end
