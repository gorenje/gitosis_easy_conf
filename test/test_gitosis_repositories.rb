require 'helper'

class TestGitosisRepositories < Test::Unit::TestCase
  context "repositories" do
    should "handle simple case" do
      @results = {}
      mock(@results).write
      mock(@results).clone { nil }
      mock(IniFile).new("fubar") { @results }

      Gitosis.config do
        filename "fubar"
      end
      Gitosis.forkers do
        dev1 "dev.one.key"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end
      Gitosis.repositories do
        fritz :writable => :developers
      end

      assert_equal ["gitosis","group fritz.writable"], @results.keys
      assert_equal( {}, @results["gitosis"])
      assert_equal ["members","writable"], @results["group fritz.writable"].keys
      assert_equal "dev.one.key", @results["group fritz.writable"]["members"]
      assert_equal "fritz", @results["group fritz.writable"]["writable"]
    end
  end
end
