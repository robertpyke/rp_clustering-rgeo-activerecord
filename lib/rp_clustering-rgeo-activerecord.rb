require "rp_clustering-rgeo-activerecord/version"

module RPClustering

  module RGeo

    module ActiveRecord

      module SpatialExpressions

        # ST_SnapToGrid: http://postgis.refractions.net/documentation/manual-2.0/ST_SnapToGrid.html
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

          ::RGeo::ActiveRecord::SpatialNamedFunction.new('ST_SnapToGrid', args, [true, true, false])
        end

      end

    end

  end

end
