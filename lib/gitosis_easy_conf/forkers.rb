module Gitosis
  extend self

  class Forker
    def initialize(&block)
      @forkers = {}
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0

        if @forkers.values.include?(args.first.to_s)
          raise(ArgumentError, "Public key '#{args.first.to_s}' has duplicate usage: " +
                "#{method} and #{@forkers.invert[args.first.to_s]}")
        end

        if @forkers.keys.include?(method)
          raise(ArgumentError, "Forker '#{method}' already has key: " +
                "#{@forkers[method]}")
        end

        @forkers[method] = args.first.to_s
      else
        @forkers[method]
      end
    end

    def [](name)
      send(name.to_sym)
    end

    def all
      @forkers.keys
    end
  end

  def forkers(&block)
    block_given? ? @@forkers = Forker.new(&block) : (@@forkers ||= nil)
  end
end

class Forker
  class << self
    def [](name)
      t = Gitosis.forkers.send(name.to_sym)
      raise ArgumentError, "Forker '#{name}' Not Found" unless t
      t
    end
  end
end
