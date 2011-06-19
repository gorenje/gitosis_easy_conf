require 'helper'

class TestGitosisRepositories < Test::Unit::TestCase

  context "repository exception handling" do
    setup do
      # write call does not happen
      @results = {}
      mock(@results).clone { nil }
      mock(IniFile).new("fubar") { @results }
    end

    should 'not allow unknown groups' do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end

      assert_raises Gitosis::UnknownGroup do
        Gitosis.repositories do
          gitosis_admin(:writable => :developers1)
        end
      end
    end

    should "not allow unknown forkers - string" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.forkers do
        dev1 "dev.one.key"
        dev2 "dev.two.key"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end
      assert_raises Gitosis::UnknownForker do
        Gitosis.repositories do
          gitosis_admin(:writable => :developers,
                        :forks    => 'dev3')
        end
      end
    end

    should "not allow unknown forkers - symbol" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.forkers do
        dev1 "dev.one.key"
        dev2 "dev.two.key"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end
      assert_raises Gitosis::UnknownForker do
        Gitosis.repositories do
          gitosis_admin(:writable => :developers,
                        :forks    => :dev3)
        end
      end
    end
  end

  context "repositories" do
    setup do
      @results = {}
      mock(@results).write
      mock(@results).clone { nil }
      mock(IniFile).new("fubar") { @results }
    end

    should "handle the simplest case" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.repositories do
        with_base_configuration({}) do
          empty_repo
          another_empty_repo
        end
      end
      assert_config({}, "simplest case")
    end

    should "provide a base_configuration stanza" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.repositories do
        with_base_configuration({ :writable => ['key.one', 'key.two'],
                                  :readable => 'key.three' }) do
          gitosis_admin :readable => 'dev.four'
          another_repo :writable => 'another.developer'
          a_third_repo :name => 'fubar-a-third-repo'
          a_fourth_repo
        end
        no_base_config_repo :writable => 'me.you.them'
      end

      assert_config({ "group another_repo.readonly" => {
                        "members" => "key.three",
                        "readonly" => "another_repo"
                      },
                      "group another_repo.writable" => {
                        "members" => "key.one key.two another.developer",
                        "writable" => "another_repo"
                      },
                      "group fubar-a-third-repo.readonly" => {
                        "members" => "key.three",
                        "readonly" => "fubar-a-third-repo"
                      },
                      "group fubar-a-third-repo.writable" => {
                        "members" => "key.one key.two",
                        "writable" => "fubar-a-third-repo"
                      },
                      "group gitosis_admin.readonly" => {
                        "members" => "key.three dev.four",
                        "readonly" => "gitosis_admin"
                      },
                      "group gitosis_admin.writable" => {
                        "members" => "key.one key.two",
                        "writable" => "gitosis_admin"
                      },
                      "group no_base_config_repo.writable" => {
                        "members" => "me.you.them",
                        "writable" => "no_base_config_repo"
                      },
                      "group a_fourth_repo.readonly" => {
                        "members" => "key.three",
                        "readonly" => "a_fourth_repo"
                      },
                      "group a_fourth_repo.writable" => {
                        "members" => "key.one key.two",
                        "writable" => "a_fourth_repo"
                      },
                    },"with base config")
    end

    should "allow just repositories definition" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.repositories do
        gitosis_admin(:writable => ['key.one', 'key.two'],
                      :readable => 'key.three')
      end

      assert_config({"group gitosis_admin.writable" => {
                        "members" => "key.one key.two",
                        "writable" => "gitosis_admin"
                      },
                      "group gitosis_admin.readonly" => {
                        "members" => "key.three",
                        "readonly" => "gitosis_admin"
                      },
                    },"just repositories defined")
    end

    should "allow string forkers and string developers that aren't a group/role" do
      Gitosis.config do
        filename "fubar"
      end
      Gitosis.forkers do
        dev1 "dev.one.key"
        dev2 "dev.two.key"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end
      Gitosis.repositories do
        gitosis_admin(:writable => [:developers, 'key.specific'],
                      :forks    => ['dev1', :dev2])
      end

      assert_config({"group gitosis_admin.writable" => {
                        "members" => "dev.one.key key.specific",
                        "writable" => "gitosis_admin"
                      },
                      "group fork.gitosis_admin.dev1.writable" => {
                        "members" => "dev.one.key",
                        "writable" => "dev1_gitosis_admin"
                      },
                      "group fork.gitosis_admin.dev2.writable" => {
                        "members" => "dev.two.key",
                        "writable" => "dev2_gitosis_admin"
                      },
                    },"string roles + forks")
    end



    should "forking and naming convention" do
      Gitosis.config do
        filename "fubar"
        fork_naming_convention do |*args|
          "[%s]=={%s}" % args.map { |a| a.to_s}
        end
      end
      Gitosis.forkers do
        dev1 "dev.one.key"
        dev2 "dev.two.key"
      end
      Gitosis.roles do
        developers Forker[:dev1]
      end
      Gitosis.repositories do
        gitosis_admin(:writable => [:developers,'dev.three.key'],
                      :name     => "gitosis-admin",
                      :forks    => :dev2)
      end

      assert_config({"group gitosis-admin.writable" => {
                        "members" => "dev.one.key dev.three.key",
                        "writable" => "gitosis-admin"
                      },
                      "group fork.gitosis-admin.dev2.writable" => {
                        "members" => "dev.two.key",
                        "writable" => "[gitosis-admin]=={dev2}"
                      },
                    },"forking and name convention")
    end

    should "repo_naming" do
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
        gitosis_admin :writable => :developers, :name => "gitosis-admin"
      end

      assert_config({"group gitosis-admin.writable" => {
                        "members" => "dev.one.key",
                        "writable" => "gitosis-admin"
                      }
                    },"handle repository naming")
    end

    should "handle simple case" do
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

      assert_config({"group fritz.writable" => {
                        "members" => "dev.one.key",
                        "writable" => "fritz"
                      }
                    },"handle simple case")
    end
  end
end
