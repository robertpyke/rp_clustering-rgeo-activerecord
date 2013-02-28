# Author: Robert Pyke

module RPClustering

  module RGeo

    module ActiveRecord

      module ArelTableSpatialExpressions

        # ST_SnapToGrid: http://www.postgis.org/docs/ST_SnapToGrid.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_SnapToGrid(geometry geomA, float size);
        #
        # Returns a geometry collection

        def st_snaptogrid(geom_a, grid_size)
          args = [geom_a, grid_size.to_s]

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_SnapToGrid', args, [true, true, false]
          )

        end

        # ST_Collect: http://www.postgis.org/docs/ST_Collect.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_Collect(geometry[] g1_array);
        #
        # This variant is an aggregate, it operates on rows of data.
        #
        # Returns a geometry collection

        def st_collect(g1_array)
          args = [g1_array]

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_Collect', args, [true, true]
          )

        end

        # ST_AsText: http://www.postgis.org/docs/ST_AsText.html
        #
        # Returns a string (WKT)

        def st_astext(g)
          args = [g]

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_AsText', args, [true, true]
          )

        end

        # ST_Centroid: http://www.postgis.org/docs/ST_Centroid.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_Centroid(geometry g1);
        #
        # Returns a geometry

        def st_centroid(g)
          args = [g]

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_Centroid', args, [true, true]
          )
        end

        # ST_MinimumBoundingCircle: http://www.postgis.org/docs/ST_MinimumBoundingCircle.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_MinimumBoundingCircle(geometry geomA, integer num_segs_per_qt_circ=48);
        #
        # Returns a geometry

        def st_minimumboundingcircle(g, num_segs=nil)
          args = [g]
          if num_segs
            args << num_segs.to_s

            ::RGeo::ActiveRecord::SpatialNamedFunction.new(
              'ST_MinimumBoundingCircle', args, [true, true, false]
            )
          else
            ::RGeo::ActiveRecord::SpatialNamedFunction.new(
              'ST_MinimumBoundingCircle', args, [true, true]
            )
          end
        end

      end

    end

  end

end
