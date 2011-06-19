# Group definition use strings and symbols to define groups with mutliple members and
# shared membership:
#   Gitosis.groups do
#     fubar 'public.key'
#     snafu :fubar
#     luke 'fubar'
#     combined :luke, :snafu, :fubar
#   end
#
# This means that the following have the values:
#   Gitosis.groups[:fubar] ==> 'public.key'
#   Gitosis.groups[:snafu] ==> 'public.key'
#   Gitosis.groups[:luke] ==> 'fubar'
#   Gitosis.groups[:combined] ==> 'public.key fubar'
#
# String values are public keys and symbols are references to group names.
# Duplicate key names are removed and returned is a concatenation of all keys.
#
module Gitosis
  class Group

    def initialize(&block)
      @groups = {}
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0
        @groups[method.to_sym] = args
      else
        raise UnknownGroup, "Unkown group '#{method}'" unless @groups[method]
        @groups[method].uniq.join(" ")
      end
    end

    def denormalize
      @groups.keys.each do |key|
        @groups[key] = @groups[key].collect do |member|
          @_refs = []
          denormalize_member(member)
        end.flatten
      end
      self
    end

    def [](name)
      send(name)
    end

    private

    def denormalize_member(member)
      case member
      when String then member
      when Symbol
        if @_refs.include?(member)
          raise SelfReferencingGroup, "Group '#{member}' cycle reference"
        end
        @_refs << member

        raise UnknownGroup, "Unkown group '#{member}'" unless @groups[member]

        @groups[member].collect { |a| denormalize_member(a) }
      else
        raise UnknownGroupType, "Group '#{member}' type not supported: #{member.class}"
      end
    end
  end
end
