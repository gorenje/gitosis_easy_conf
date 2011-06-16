module Gitosis
  extend self

  class Forker
    def initialize(&block)
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0
        (@@forkers ||= {})[method.to_sym] = args.first
      else
        @@forkers[method]
      end
    end

    def all
      @@forkers.keys
    end
  end

  def forkers(&block)
    block_given? ? @@forkers = Forker.new(&block) : @@forkers
  end
end

class Forker < Gitosis::Forker
  class << self
    def [](name)
      t = @@forkers[name.to_sym]
      raise "Forker '#{name}' Not Found" unless t
      t
    end
  end
end
