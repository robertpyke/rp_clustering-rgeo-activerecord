require "rp_clustering-rgeo-activerecord/version"

module RPClustering

  module RGeo

    module ActiveRecord

      module AttributeSpatialExpressions

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

          ::RGeo::ActiveRecord::SpatialNamedFunction.new(
            'ST_SnapToGrid', args, [true, true, false]
          )
        end

        # ST_Collect: http://postgis.refractions.net/documentation/manual-2.0/ST_Collect.html
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

      end

      # Attach our Spatial Expression methods onto the Arel::Attribute class.
      #
      # i.e. As stated in the RGeo::ActiveRecord docs.. Allow chaining of spatial expressions from attributes
      ::Arel::Attribute.class_eval do
        include ::RPClustering::RGeo::ActiveRecord::AttributeSpatialExpressions
      end

    end

  end

end
