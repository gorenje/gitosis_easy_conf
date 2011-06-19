require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'inifile'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'gitosis_easy_conf'

class Test::Unit::TestCase
  include RR::Adapters::TestUnit

  # used in the repository tests, compares the complete gitosis configuration.
  # assumes the existence of @results hash.
  def assert_config(expected,msg)
    assert_equal( (["gitosis"] + expected.keys).sort, @results.keys.sort,
                  msg + " (top level keys)")
    assert_equal( {}, @results["gitosis"], msg + " (empty gitosis)")

    expected.keys.each do |group_keys|
      gmsg = msg + " [#{group_keys}]"
      assert_equal(expected[group_keys].keys.sort,
                   @results[group_keys].keys.sort, gmsg+" (prop keys)")

      exp, com = expected[group_keys], @results[group_keys]
      exp.keys.each do |property_key|
        assert_equal exp[property_key], com[property_key], gmsg + " [#{property_key}]"
      end
    end
  end
end
