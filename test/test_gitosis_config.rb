require 'helper'

class TestGitosisConfig < Test::Unit::TestCase
  context "config" do

    should "return a config hash if block given" do
      Gitosis.config do
        fubar(:one,:two) do
          puts "blah"
        end
      end
      assert_equal [:one,:two], Gitosis.config.fubar.first
      assert Gitosis.config.fubar.last.is_a?(Proc)
    end

    should "return a filename" do
      Gitosis.config do
        filename
      end
      assert_equal nil, Gitosis.config.filename

      Gitosis.config do
        filename do
          puts "blah"
        end
      end
      assert_equal nil, Gitosis.config.filename

      Gitosis.config do
        filename("fubar","snafu") do
          puts "blah"
        end
      end
      assert_equal "fubar", Gitosis.config.filename
    end

    should "return a fork_name_convention" do
      Gitosis.config do
        fork_name_convention
      end
      assert_equal nil,  Gitosis.config.fork_naming_convention

      Gitosis.config do
        fork_name_convention("one")
      end
      assert_equal nil,  Gitosis.config.fork_naming_convention

      Gitosis.config do
        fork_naming_convention("fubar","snafu") do |para,para2|
          "#{para}+#{para2}"
        end
      end
      assert_equal Proc,  Gitosis.config.fork_naming_convention.class
      assert_equal "1+2", Gitosis.config.fork_naming_convention.call("1","2")

      Gitosis.config do
        fork_naming_convention do |para,para2|
          "#{para}+#{para2}"
        end
      end
      assert_equal Proc,  Gitosis.config.fork_naming_convention.class
      assert_equal "1+2", Gitosis.config.fork_naming_convention.call("1","2")

      Gitosis.config do
        fork_naming_convention do |*args|
          '%s+%s' % args.map { |a| a.to_s }
        end
      end
      assert_equal Proc,  Gitosis.config.fork_naming_convention.class
      assert_equal "1+2", Gitosis.config.fork_naming_convention.call("1","2")
    end

    should "fork_name_convention should complain if arity is not correct" do
      assert_raises Gitosis::BlockArityIncorrect do
        Gitosis.config do
          fork_naming_convention("fubar","snafu") do
            nil
          end
        end
      end

      assert_raises Gitosis::BlockArityIncorrect do
        Gitosis.config do
          fork_naming_convention("fubar","snafu") do |a|
            nil
          end
        end
      end

      assert_raises Gitosis::BlockArityIncorrect do
        Gitosis.config do
          fork_naming_convention("fubar","snafu") do |a,b,c|
            nil
          end
        end
      end
    end
  end
end
