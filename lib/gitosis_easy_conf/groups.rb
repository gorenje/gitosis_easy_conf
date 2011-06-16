module Gitosis
  extend self

  class Group
    def initialize(&block)
      instance_eval(&block)
    end

    def method_missing(method, *args, &block)
      if args.length > 0
        (@groups ||= {})[method.to_sym] = args
      else
        @groups[method].uniq.join(" ")
      end
    end

    def denormalize_member(member)
      case member
      when String then member
      when Symbol then @groups[member].collect { |a| denormalize_member(a) }
      end
    end

    def denormalize
      @groups.keys.each do |key|
        @groups[key] = @groups[key].collect do |member|
          self.denormalize_member(member)
        end.flatten
      end
      self
    end

    def [](name)
      denormalize_member(name)
    end
  end

  def groups(&block)
    block_given? ? @@groups = Group.new(&block).denormalize : @@groups
  end
  alias :roles :groups
end
