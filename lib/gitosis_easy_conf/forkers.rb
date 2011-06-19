# Define a mapping from a Gitosis user and their public key. Here the use of string and
# symbol are unimportant, i.e.
#   Gitosis.forkers do
#      fubar :key_one
#      fubar "key_one"
#   end
# are equivalent.
#
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
          raise(SamePublicKeyForForkers, "Key '#{args.first}' used by '#{method}' "+
                "and #{@forkers.invert[args.first.to_s]}'")
        end

        if @forkers.keys.include?(method)
          raise(ForkerAlreadyDefined, "Forker '#{method}' already defined with key: " +
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
end

