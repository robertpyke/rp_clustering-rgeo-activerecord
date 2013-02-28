require 'test/unit'
require 'rgeo/active_record/adapter_test_helper'
require 'rp_clustering-rgeo-activerecord'
require 'squeel'

module RPClustering
  module RGeo
    module ActiveRecord
      module Tests
        class MyUnitTest < Test::Unit::TestCase  # :nodoc:

          # Use the RGEO active record adapter test helper

          DATABASE_CONFIG_PATH = ::File.dirname(__FILE__)+'/database.yml'
          OVERRIDE_DATABASE_CONFIG_PATH = ::File.dirname(__FILE__)+'/database_local.yml'
          include ::RGeo::ActiveRecord::AdapterTestHelper


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

            # Test that the st_snaptogrid method exists on the Arel::Attribute
            # and on the Arel::Table

            def test_st_snaptogrid_method_should_exist
              arel_klass = populate_ar_class(:latlon_point)
              assert(
                arel_klass.arel_table[:latlon_point].methods.include?(:st_snaptogrid),
                "Active Record Arel::Attribute should now have a st_snaptogrid function. " +
                "Found:\n#{arel_klass.arel_table[:latlon_point].methods.sort}"
              )

              assert(
                arel_klass.arel_table.methods.include?(:st_snaptogrid),
                "Active Record Arel::Table should now have a st_snaptogrid function. " +
                "Found:\n#{arel_klass.arel_table.methods.sort}"
              )
            end

            # Confirm that the st_snaptogrid function is producing the 
            # expected results

            def test_st_snap_to_grid
              arel_klass = populate_ar_class(:latlon_point)

              points_generated = 0
              (-5..5).each do |lng|
                (-5..5).each do |lat|
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

              attr = arel_klass.arel_table[:latlon]
              t = arel_klass.arel_table

              q1 = arel_klass.select(t.st_astext(t.st_centroid(t.st_collect(attr))).as("cluster_centroid"))
              q1 = q1.group(attr.st_snaptogrid(180))

              assert_equal(1, q1.all.count(), "With a sufficiently large grid size, we would expect the st_snaptogrid to produce only a single point")


              value = q1.first["cluster_centroid"]
              compare_point = @geographic_factory.point(0,0)
              assert_equal(@geographic_factory.parse_wkt(value), compare_point, "cluster centroid should be a valid point in the center of the earth")

              q2 = arel_klass.select(t.st_astext(t.st_centroid(t.st_collect(attr))).as("cluster_centroid"))
              q2 = q2.group(attr.st_snaptogrid(1))

              assert_equal(points_generated, q2.all.count(), "With a small grid size, we would expect the st_snaptogrid to produce every single point")

            end

            # Confirm that the st_minimumboundingcircle function is producing the 
            # expected results

            def test_st_minimumboundingcircle
              arel_klass = populate_ar_class(:latlon_point)

              points_generated = 0
              (-5..5).each do |lng|
                (-5..5).each do |lat|
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

              attr = arel_klass.arel_table[:latlon]
              t = arel_klass.arel_table

              q1 = arel_klass.select(t.st_astext(t.st_minimumboundingcircle(attr.st_collect())).as("min_bound_circle"))

              assert_equal(1, q1.all.count(), "We should get a single bounding circle covering all points")

              value = q1.first["min_bound_circle"]
              circle = @geographic_factory.parse_wkt(value)
              assert(circle.is_a?(::RGeo::Feature::Polygon), "the min_bound_circle should be a polygon")

              q2 = arel_klass.where{latlon.op('&&', circle)}
              assert_equal(points_generated, q2.count(), "the min_bound_circle should contain all our generated poits")

            end

          end
        end
      end
    end
  end
end
