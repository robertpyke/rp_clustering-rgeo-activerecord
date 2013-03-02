# Author: Robert Pyke

module RPClustering

  module RGeo

    module ActiveRecord

      module BaseSpatialExpressions

        # Use ActiveSupport::Concern to seperate our
        # class and instance methods for inclusion into ActiveRecord::Base
        extend ActiveSupport::Concern

        module ClassMethods

          # === Cluster using the PostGIS function ST_SnapToGrid
          #
          # attr_to_cluster is the name of attribute to be clustered (a symbol).
          # The attribute should be a geometry attribute.
          #
          # Use the options Hash to define what cluster properties you would
          # like returned.
          #
          # == Options:
          #
          # [:grid_size] if set, will be used to create the cluster. The clustering
          #              works rougly like this; all geometries within 'grid_size' of each other
          #              will be pulled together to form a single cluster. For a detailed
          #              explanation, please see the PostGIS docs for ST_SnapToGrid.
          #
          #              If no +:grid_size+ is given, clusters will consist of all 'equal'
          #              geometries. E.g. all points at the same 
          #              position (x,y) will be pulled together to form a single cluster.
          #              This is actually just a Group By of your +attr_to_cluster+.
          #
          # [:cluster_geometry_count] if set to true, the query will select, for
          #                           each cluster, the number of geometries in the cluster.
          #
          # [:cluster_geometry_count_as] the name to select the
          #                              cluster_geometry_count as, defaults 
          #                              to "cluster_geometry_count".
          #
          # [:cluster_centroid] if set to true, the query will select, for
          #                     each cluster, the cluster centroid. The 
          #                     cluster_centroid returned will be a WKT string.
          #
          # [:cluster_centroid_as] the name to select the cluster_centroid
          #                        as, defaults to "cluster_centroid".
          #
          # [:cluster_minimum_bounding_circle] if set to true, the query will select,
          #                                    for each cluster, the minimum
          #                                    bouding circle. The
          #                                    cluster_minimum_bounding_circle
          #                                    will be a WKT string.
          #
          # [:cluster_minimum_bounding_circle_as] the name to select the
          #                                       cluster_minimum_bounding_circle as,
          #                                       defaults to "cluster_minimum_bounding_circle"
          #
          # == Note
          #
          # Using the options hash, you must 'select' at least one attribute,
          # else this method will raise an ArgumentError.
          #

          def cluster_by_st_snap_to_grid(attr_to_cluster, options={})
            raise ArgumentError, "Invalid cluster_by_st_snap_to_grid options provided" unless _are_cluster_options_valid?(options)

            grid_size = options[:grid_size]

            arel_table = self.arel_table
            arel_attr  = arel_table[attr_to_cluster]

            q = self

            # Get the cluster geometry count (if asked to)
            if options[:cluster_geometry_count]
              cluster_geometry_count_as = options[:cluster_geometry_count_as] || "cluster_geometry_count"
              q = q._select_cluster_geometry_count(attr_to_cluster, cluster_geometry_count_as)
            end

            if options[:cluster_centroid]
              cluster_centroid_as = options[:cluster_centroid_as] || "cluster_centroid"
              q = q._select_cluster_centroid_as_wkt(attr_to_cluster, cluster_centroid_as)
            end

            if options[:cluster_minimum_bounding_circle]
              cluster_minimum_bounding_circle_as = options[:cluster_minimum_bounding_circle_as] || "cluster_minimum_bounding_circle"
              q = q._select_cluster_minimum_bounding_circle_as_wkt(attr_to_cluster, cluster_minimum_bounding_circle_as)
            end

            if grid_size
              q = q.group(arel_attr.st_snaptogrid(grid_size))
            else
              q = q.group(arel_attr)
            end

            q
          end

          # Ensure the user is selecting something, and that
          # the grid size is either nil, or is a valid integer

          def _are_cluster_options_valid?(options)
            selecting_something = (
              options[:cluster_geometry_count] or
              options[:cluster_centroid] or
              options[:cluster_minimum_bounding_circle]
            )

            grid_size_valid = (
              options[:grid_size].nil? or
              ( options[:grid_size].is_a? Numeric and options[:grid_size] >= 0 )
            )

            valid = selecting_something and grid_size_valid
          end

          # Select the cluster geometry count 

          def _select_cluster_geometry_count(attr_to_cluster, as)
            arel_table = self.arel_table
            arel_attr  = arel_table[attr_to_cluster]

            select(arel_attr.count().as(as))
          end

          # Select the cluster centroid as WKT.

          def _select_cluster_centroid_as_wkt(attr_to_cluster, as)
            arel_table = self.arel_table
            arel_attr  = arel_table[attr_to_cluster]

            select(
              arel_table.st_astext(
                arel_table.st_centroid(arel_attr.st_collect)
              ).as(as)
            )
          end

          # Select the cluster minimum bounding circle as WKT.

          def _select_cluster_minimum_bounding_circle_as_wkt(attr_to_cluster, as)
            arel_table = self.arel_table
            arel_attr  = arel_table[attr_to_cluster]

            select(
              arel_table.st_astext(
                arel_table.st_minimumboundingcircle(arel_attr.st_collect)
              ).as(as)
            )
          end

        end
      end
    end
  end
end
