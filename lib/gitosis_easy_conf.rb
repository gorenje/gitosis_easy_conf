require 'gitosis_easy_conf/repositories'
require 'gitosis_easy_conf/groups'
require 'gitosis_easy_conf/forkers'
require 'gitosis_easy_conf/config'

module Gitosis
  # Exceptions
  %w[
    SelfReferencingGroup     UnknownForker            UnknownGroup
    UnknownGroupType         SamePublicKeyForForkers  ForkerAlreadyDefined
    BlockArityIncorrect
  ].each do |exception_name|
    const_set( exception_name, Class.new(StandardError))
  end

  # Configuration verbs -- config, forkers, groups (or roles) and repositories.
  def config(&block)
    block_given? ? @@config = Config.new(&block) : (@@config ||= nil)
  end

  def forkers(&block)
    block_given? ? @@forkers = Forker.new(&block) : (@@forkers ||= nil)
  end

  def groups(&block)
    block_given? ? @@groups = Group.new(&block).denormalize : (@@groups ||= nil)
  end
  alias :roles :groups

  def repositories(&block)
    Repository.new(&block).write
  end
end

# shortcut to access the forkers.
class Forker
  class << self
    def [](name)
      t = Gitosis.forkers.send(name.to_sym)
      raise Gitosis::UnknownForker, "Forker '#{name}' Not Found" unless t
      t
    end
  end
end
