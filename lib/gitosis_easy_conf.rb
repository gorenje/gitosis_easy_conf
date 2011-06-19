require 'gitosis_easy_conf/repositories'
require 'gitosis_easy_conf/groups'
require 'gitosis_easy_conf/forkers'
require 'gitosis_easy_conf/config'

module Gitosis
  extend self

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
    if block_given?
      if defined?(@@config)
        @@config.instance_eval(&block)
      else
        @@config = Config.new(&block)
      end
    else
      @@config ||= Config.new(){}
    end
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
    @@config = Config.new(){}
  end

  def setup(filename = nil, &block)
    config do
      filename filename
    end if filename

    class_eval(&block)
  end
end

class Forker
  class << self
    def [](name)
      Gitosis.forkers.send(name.to_sym)
    end
  end
end
