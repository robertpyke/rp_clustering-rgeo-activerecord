require "rp_clustering-rgeo-activerecord/version"
require "rp_clustering-rgeo-activerecord/active_record_base_spatial_expressions"
require "rp_clustering-rgeo-activerecord/arel_attribute_spatial_expressions"
require "rp_clustering-rgeo-activerecord/arel_table_spatial_expressions"

module RPClustering

  module RGeo

    module ActiveRecord

      # Spatial Expressions to be attached directly to ActiveRecord::Base

      module BaseSpatialExpressions
      end

      # Attach our Spatial Expression methods onto the ActiveRecord::Base class.

      ::ActiveRecord::Base.class_eval do
        include ::RPClustering::RGeo::ActiveRecord::BaseSpatialExpressions
      end

      # Spatial Expressions to be attached directly to Arel Attributes (DB columns)

      module ArelAttributeSpatialExpressions
      end

      # Attach our Spatial Expression methods onto the Arel::Attribute class.
      #
      # i.e. As stated in the RGeo::ActiveRecord docs.. Allow chaining of spatial expressions from attributes

      ::Arel::Attribute.class_eval do
        include ::RPClustering::RGeo::ActiveRecord::ArelAttributeSpatialExpressions
      end

      # Spatial Expressions to be attached to Arel Table (DB tables)

      module ArelTableSpatialExpressions
      end

      # Attach our Spatial Expression methods onto the Arel::Table class.

      ::Arel::Table.class_eval do
        include ::RPClustering::RGeo::ActiveRecord::ArelTableSpatialExpressions
      end

    end

  end

end
