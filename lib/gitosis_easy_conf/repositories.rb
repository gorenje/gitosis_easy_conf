require 'inifile'

module Gitosis
  extend self

  class Repository
    def initialize(&block)
      @conffile = IniFile.new(Gitosis.config.filename)
      @conffile["gitosis"] = {}

      @origconffile = @conffile.clone

      @fork_name = Gitosis.config.fork_naming_convention || lambda do |repo,forker|
        "#{forker}_#{repo}"
      end

      instance_eval(&block)
    end

    def write
      if @conffile.eql?(@origconffile)
        puts "No changes, no update of #{Gitosis.config.filename}"
      else
        puts "Updating #{Gitosis.config.filename}"
        @conffile.write
      end
    end

    def method_missing(method, *args, &block)
      method = (args.first[:name] || method).to_sym

      committers = [args.first[:writable]].flatten.compact.collect do |member|
        Gitosis.groups[member]
      end.flatten

      @conffile["group #{method}.writable"] = {
        'members' => committers.join(' '),
        'writable' => method.to_s
      }

      readers = [args.first[:readable]].flatten.compact.collect do |member|
        Gitosis.groups[member]
      end.flatten

      @conffile["group #{method}.readonly"] = {
        'members' => readers.join(' '),
        'readonly' => method.to_s
      } unless readers.empty?

      [args.first[:forks]].flatten.compact.
        collect { |a| a == :all ? Gitosis.forkers.all : a }.flatten.compact.each do |forker|
        @conffile["group fork.#{method}.#{forker}.writable"] = {
          'members' => ::Forker[forker],
          'writable' => @fork_name.call(method,forker)
        }
        @conffile["group fork.#{method}.#{forker}.readonly"] = {
          'members' => readers.join(' '),
          'readonly' => @fork_name.call(method,forker)
        }
      end
    end
  end

  def repositories(&block)
    Repository.new(&block).write
  end
end

