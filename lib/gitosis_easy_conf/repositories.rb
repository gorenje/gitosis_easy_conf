require 'inifile'

module Gitosis
  extend self

  class Repository
    def initialize(&block)
      @conffile = IniFile.new("tmp.conf")
      instance_eval(&block)
    end

    def write
      @conffile.write
    end

    def method_missing(method, *args, &block)
      puts "A.first: [#{method}] #{args.first}"
      committers = [args.first[:writable]].flatten.compact.collect do |member|
        Gitosis.groups[member]
      end.flatten

      @conffile["group #{method}.write"]['writable'] = method
      @conffile["group #{method}.write"]['members'] = committers.join(' ')

      readers = [args.first[:readable]].flatten.compact.collect do |member|
        Gitosis.groups[member]
      end.flatten

      @conffile["group #{method}.readonly"]['readonly'] = method
      @conffile["group #{method}.readonly"]['members'] = readers.join(' ')

      puts "Repo: #{method}, has committers: #{committers.join(',')}"
      puts "Repo: #{method}, has readers: #{readers.join(',')}"
    end
  end

  def repositories(&block)
    Repository.new(&block).write
  end
end

