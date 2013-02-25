require 'test/unit'
require 'rgeo/active_record/adapter_test_helper'
require 'rp_clustering-rgeo-activerecord'

class MyUnitTest < Test::Unit::TestCase  # :nodoc:

  # Use the active record adapter test helper

  DATABASE_CONFIG_PATH = ::File.dirname(__FILE__)+'/database.yml'
  OVERRIDE_DATABASE_CONFIG_PATH = ::File.dirname(__FILE__)+'/database_local.yml'
  include RGeo::ActiveRecord::AdapterTestHelper


  define_test_methods do

    def populate_ar_class(content_)
      klass_ = create_ar_class
      case content_
      when :latlon_point
        klass_.connection.create_table(:spatial_test) do |t_|
          t_.column 'latlon', :point, :srid => 4326
        end
      end
      klass_
    end


    # Confirm that everything is working as it should
    def test_should_pass
      assert(true)
    end

    def test_should_have_a_version
      assert_not_nil(RPClustering::RGeo::ActiveRecord::VERSION)
    end

    def test_st_snap_to_grid
      arel_klass = populate_ar_class(:latlon_point)

      points_generated = 0
      (-20..20).each do |lng|
        (-20..20).each do |lat|
          obj = arel_klass.new
          obj.latlon = @geographic_factory.point(lng, lat)
          obj.save!
          points_generated+=1
        end
      end

      # Sanity check, confirm that we have all the points we created.
      count_res = arel_klass.count()
      assert_equal(
        points_generated,
        count_res,
        "The number of points generated doesn't match the number in the DB"
      )

      flunk("This test is work in progress")

    end

    def test_query_point
      arel_klass = populate_ar_class(:latlon_point)
      obj = arel_klass.new
      obj.latlon = @geographic_factory.point(1, 2)
      obj.save!
      id = obj.id
      obj2 = arel_klass.where(:latlon => @geographic_factory.multi_point([@geographic_factory.point(1, 2)])).first
      assert_equal(id, obj2.id)
      obj3 = arel_klass.where(:latlon => @geographic_factory.point(2, 2)).first
      assert_nil(obj3)
    end

  end
end
