# Author: Robert Pyke

module RPClustering

  module RGeo

    module ActiveRecord

      module ArelAttributeSpatialExpressions

        # ST_SnapToGrid: http://www.postgis.org/docs/ST_SnapToGrid.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_SnapToGrid(geometry geomA, float size);
        #
        # Returns a geometry collection

        def st_snaptogrid(grid_size)
          args = [self, grid_size.to_s]

          # SpatialNamedFunction takes the following args:
          # * name
          # * expr
          # * spatial_flags
          # * aliaz (defaults to nil)
          #
          #
          # Understanding the spatial_flags argument
          # -----------------------------------------
          #
          # A flag is true if the corresponding argument is spatial, else the
          # flag is false.
          # The first element is the spatial-ness result, the other args
          # relate to our expression args

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
        # Returns a geometry collection

        def st_collect()
          args = [self]

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_Collect', args, [true, true]
          )

        end

        # ST_MinimumBoundingCircle: http://www.postgis.org/docs/ST_MinimumBoundingCircle.html
        #
        # Implements postgis function variant:
        #
        #   geometry ST_MinimumBoundingCircle(geometry geomA, integer num_segs_per_qt_circ=48);
        #
        # Returns a geometry

        def st_minimumboundingcircle(num_segs=nil)
          args = [self]
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
