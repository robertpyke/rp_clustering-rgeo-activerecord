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

            def test_cluster_by_st_snap_to_grid_exists
              arel_klass = populate_ar_class(:latlon_point)
              assert(
                arel_klass.methods.include?(:cluster_by_st_snap_to_grid),
                "ActiveRecord::Base should now have a cluster_by_st_snap_to_grid function. " +
                "Found:\n#{arel_klass.methods.sort}"
              )
            end

            def test_cluster_by_st_snap_to_grid_should_exception_with_invalid_options
              arel_klass = populate_ar_class(:latlon_point)

              assert_raise(ArgumentError) do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size: 10)
              end

              assert_raise(ArgumentError) do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size:  -12, cluster_geometry_count: true)
              end

              assert_raise(ArgumentError) do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size:  "2", cluster_geometry_count: true)
              end

              assert_nothing_thrown do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size:  2, cluster_geometry_count: true)
              end

              assert_nothing_thrown do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size:  2, cluster_centroid: true)
              end

              assert_nothing_thrown do
                res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size:  2, cluster_minimum_bounding_circle: true)
              end

            end

            def test_clustering_with_a_sufficiently_large_grid_size_reduces_count
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

              res = arel_klass.cluster_by_st_snap_to_grid(:latlon, grid_size: 5, cluster_geometry_count: true)
              clusters = res.all
              total_clusters = clusters.count()

              points_found_in_clusters = 0

              res.all.each do |cluster|
                points_found_in_clusters += cluster["cluster_geometry_count"].to_i
              end

              assert_equal(points_generated, points_found_in_clusters,
                "The sum of the size of our clusters should equal the number of points in the table"
              )

              # We should have less clusters than we have points
              assert(total_clusters < points_generated, "we should have less clusters than we have points")

              # We should have more than 1 cluster with this size grid
              assert(total_clusters > 1, "we should have more than 1 cluster with this grid size")
            end

          end

        end
      end
    end
  end
end
