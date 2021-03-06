require 'helper'

class TestGitosisForker < Test::Unit::TestCase
  context "forkers" do
    should "only take the first argument" do
      Gitosis.forkers do
        fubar("one", "two") do
          nil
        end
      end

      assert_equal "one", Gitosis.forkers.fubar
      assert_equal "one", Gitosis.forkers['fubar']
    end

    should "raise error for unknown forkers" do
      Gitosis.forkers do
        fubar("one", "two") do
          nil
        end
      end

      assert_raises Gitosis::UnknownForker do
        Gitosis.forkers[:fuabr]
      end
      assert_raises Gitosis::UnknownForker do
        Gitosis.forkers.fuabr
      end
    end

    should "have shortcut method" do
      Gitosis.forkers do
        fubar("one", "two") do
          nil
        end
      end

      assert_raises Gitosis::UnknownForker do
        Forker["unknonw"]
      end
      assert_raises Gitosis::UnknownForker do
        Gitosis.forkers['unknonw']
      end
      assert_raises Gitosis::UnknownForker do
        Gitosis.forkers.unknonw
      end

      assert_equal "one", Forker["fubar"]
      assert_equal "one", Forker[:fubar]
    end

    should "return all forkers" do
      Gitosis.forkers do
      end
      assert_equal [], Gitosis.forkers.all

      Gitosis.forkers do
        dev1 "some.public.key"
        dev2 "some.other.key"
        dev3 "more.key"
      end
      assert_equal [:dev1, :dev2, :dev3], Gitosis.forkers.all
      assert_equal [:dev1, :dev2, :dev3], Forker[:all]
    end

    should "complain if using the duplicate pub keys" do
      assert_raises Gitosis::SamePublicKeyForForkers do
        Gitosis.forkers do
          fubar  "has.key"
          fubar2 "has.key"
        end
      end
      assert_raises Gitosis::SamePublicKeyForForkers do
        Gitosis.forkers do
          fubar  "haskey"
          fubar2 :haskey
        end
      end
      assert_raises Gitosis::SamePublicKeyForForkers do
        Gitosis.forkers do
          fubar "has.key"
          fubar "has.key"
        end
      end
    end

    should "complain if using the same forker name" do
      assert_raises Gitosis::ForkerAlreadyDefined do
        Gitosis.forkers do
          fubar "has.key"
          fubar "has.key.2"
        end
      end
    end
  end
end
