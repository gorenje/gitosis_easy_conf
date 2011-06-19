# Definition of a gitosis repository.
#
require 'inifile'

module Gitosis
  extend self

  EmptyConfig = {
    :writable => [], :readable => [], :forks => []
  }

  class Repository
    def initialize(&block)
      @base_config = EmptyConfig
      @conffile = IniFile.new(Gitosis.config.filename)
      @conffile["gitosis"] = {}

      @origconffile = @conffile.clone

      @fork_name = Gitosis.config.fork_naming_convention || lambda do |repo,forker|
        "#{forker}_#{repo}"
      end

      instance_eval(&block)
    end

    def write
      @conffile.write unless @conffile.eql?(@origconffile)
    end

    def with_base_configuration(config,&block)
      @base_config = config || EmptyConfig
      instance_eval(&block)
      @base_config = EmptyConfig
    end

    def method_missing(method, *args, &block)
      args = [{}] if args.first.nil?
      method = (args.first[:name] || method).to_sym

      committers = _get_keys([@base_config,args.first].map{|h| h[:writable]})
      @conffile["group #{method}.writable"] = {
        'members'  => committers,
        'writable' => method.to_s
      } unless committers == ""

      readers = _get_keys([@base_config,args.first].map{|h| h[:readable]})
      @conffile["group #{method}.readonly"] = {
        'members'  => readers,
        'readonly' => method.to_s
      } unless readers == ""

      [@base_config,args.first].map{|h| h[:forks]}.flatten.compact.
        collect { |a| a == :all ? Gitosis.forkers.all : a }.flatten.compact.each do |forker|

        fork_repo_name = @fork_name.call(method,forker)

        @conffile["group fork.#{method}.#{forker}.writable"] = {
          'members'  => ::Forker[forker],
          'writable' => fork_repo_name,
        }

        @conffile["group fork.#{method}.#{forker}.readonly"] = {
          'members'  => readers,
          'readonly' => fork_repo_name,
        } unless readers == ""
      end
    end

    private

    def _get_keys(ary)
      ary.flatten.compact.collect do |member|
        case member
        when String then member
        when Symbol then Gitosis.groups[member]
        else
          raise UnknownGroup, "Group '#{member}'"
        end
      end.flatten.join(' ')
    end
  end
end
