require 'test/unit'
require 'rp_clustering-rgeo-activerecord'

class MyUnitTest < Test::Unit::TestCase  # :nodoc:

  # Confirm that everything is working as it should
  def test_should_pass
    assert(true)
  end

  def test_should_have_a_version
    assert_not_nil(RPClustering::RGeo::ActiveRecord::VERSION)
  end
end
