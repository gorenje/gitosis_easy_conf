module Gitosis
  class Config
    def initialize(&block)
      @configs = {}
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0 || block_given?
        @configs[method] = case method
                           when :fork_naming_convention then
                             if block_given? && ![2,-1].include?(block.arity)
                               raise BlockArityIncorrect, "Block needs exactly two arguments"
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
end
