require 'helper'

class TestGitosisGroups < Test::Unit::TestCase
  context "groups" do

    should "avoid self reference" do
      assert_raises Gitosis::SelfReferencingGroup do
        Gitosis.roles do
          fubar 'fubar.bad', :fubar
        end
      end
      assert_raises Gitosis::SelfReferencingGroup do
        Gitosis.roles do
          admin :fubar
          fubar 'fubar.bad', :admin
        end
      end

      assert_raises Gitosis::SelfReferencingGroup do
        Gitosis.roles do
          snafu :admin
          admin :snafu
          fubar 'fubar.bad', :admin
        end
      end

      assert_raises Gitosis::SelfReferencingGroup do
        Gitosis.roles do
          snafu :fubar
          admin :snafu
          fubar 'fubar.bad', :admin
        end
      end
    end

    should 'raise an error if symbol is not a group' do
      assert_raises Gitosis::UnknownGroup do
        Gitosis.roles do
          fubar 'fubar.bad', :admins
        end
      end
    end

    should 'strings are key names and symbols refer to group names' do
      Gitosis.groups do
        fubar    'public.key'
        snafu    :fubar
        luke     'fubar'
        combined :luke, :snafu, :fubar
      end

      assert_equal 'public.key', Gitosis.groups[:fubar]
      assert_equal 'public.key', Gitosis.groups[:snafu]
      assert_equal 'fubar', Gitosis.groups[:luke]
      assert_equal 'fubar public.key', Gitosis.groups[:combined]
    end

    should "anything other than string or symbol causes error" do
      assert_raises Gitosis::UnknownGroupType do
        Gitosis.roles do
          fubar 1234
        end
      end
    end

    should "blocks are ignored" do
      Gitosis.roles do
        fubar "fubar" do |a|
          nil
        end
      end
      assert_equal "fubar", Gitosis.groups.fubar
    end

    should "be able to use roles" do
      Gitosis.roles do
        fubar 'fubar.bad', 'big.bear'
      end
      assert_equal 'fubar.bad big.bear', Gitosis.roles[:fubar]
      assert_equal 'fubar.bad big.bear', Gitosis.roles.fubar
    end

    should "be denormalized and uniquized" do
      Gitosis.groups do
        admins 'key.one', 'key.two', 'shared.key'
        developers 'dev.one', :admins
        deployers 'app1.deploy', 'app2.deploy', 'shared.key'
        shared_grp :admins, :deployers
        all_developers :admins, :developers
        everyone :all_developers, :deployers
      end

      groups = Gitosis.groups
      assert_equal('key.one key.two shared.key dev.one app1.deploy app2.deploy',
                   groups.everyone)
      assert_equal 'key.one key.two shared.key app1.deploy app2.deploy', groups.shared_grp
      assert_raises(Gitosis::UnknownGroup) { groups.unknown_group }
    end
  end
end
