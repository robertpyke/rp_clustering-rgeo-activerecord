# RPClustering::RGeo::ActiveRecord

[![Code Climate](https://codeclimate.com/github/robertpyke/rp_clustering-rgeo-activerecord.png)](https://codeclimate.com/github/robertpyke/rp_clustering-rgeo-activerecord)

A RGeo PostGIS extension to provide Active Record (Model) clustering functionality.

The intention is that this Gem will eventually provide abstracted methods for
both "on the fly" clustering, as well as cached clustering (including associated generators).

This Gem is currently in early development, so expect changes. On this note, if you'd like a specific clustering
algorithm or feature added, please ask.

If you find a problem with this Gem, please don't hesitate to [raise an issue](https://github.com/robertpyke/rp_clustering-rgeo-activerecord/issues).

## Installation

Note: This gem provides extensions for [activerecord-postgis-adapter](https://github.com/dazuma/activerecord-postgis-adapter).
Please see [activerecord-postgis-adapter](https://github.com/dazuma/activerecord-postgis-adapter)
for its install instructions. Once you've got
it working, then simply add this gem to your Gemfile to enable these extensions.

Add this line to your application's Gemfile:

    gem 'rp_clustering-rgeo-activerecord'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rp_clustering-rgeo-activerecord


## Usage

### Added in Version 0.0.3

This version allows for the "on the fly" use of a ST_SnapToGrid clustering function.
The function is added to ActiveRecord::Base (Models). The function is:

```ruby

# Cluster using the PostGIS function ST_SnapToGrid
# -------------------------------------------------
#
# attr_to_cluster is the name of attribute to be clustered (a symbol).
# The attribute should be geometry attribute.
#
# Use the options Hash to define what cluster properties you would
# like returned.
#
# Options:
#
# [:grid_size] if set, will be used to create the cluster. The clustering
#     works rougly like this; all geometries within 'grid_size' of each other
#     will be pulled together to form a single cluster. For a detailed
#     explanation, please see the PostGIS docs for ST_SnapToGrid.
#
#     If no +:grid_size+ is given, clusters will consist of all 'equal'
#     geometries. E.g. all points at the same 
#     position (x,y) will be pulled together to form a single cluster.
#     This is actually just a Group By of your +attr_to_cluster+.
#
# [:cluster_geometry_count] if set to true, the query will select, for
#     each cluster, the number of geometries in the cluster.
#
# [:cluster_geometry_count_as] the name to select the
#     cluster_geometry_count as, defaults to "cluster_geometry_count".
#
# [:cluster_centroid] if set to true, the query will select, for
#     each cluster, the cluster centroid. The cluster_centroid returned
#     will be a WKT string.
#
# [:cluster_centroid_as] the name to select the 
#     cluster_centroid as, defaults to "cluster_centroid".
#
# [:cluster_minimum_bounding_circle] if set to true, the query will select,
#     for each cluster, the minimum bouding circle. The cluster_minimum_bounding_circle
#     will be a WKT string.
#
# [:cluster_minimum_bounding_circle_as] the name to select the
#     cluster_minimum_bounding_circle as, defaults to "cluster_minimum_bounding_circle"
#
# Note: Using the options hash, you must 'select' at least one attribute,
# else this method will rase an ArgumentError.

cluster_by_st_snap_to_grid(attr_to_cluster, options={})

```

e.g.

```ruby


@layer = Layer.find(params[:id])

cluster_result = @layer.cluster_by_st_snap_to_grid(
  :geometry, # the column to cluster
  grid_size: 0.01,
  cluster_geometry_count: true,
  cluster_centroid: true
)

features = []
cluster_result.each do |cluster|
  geom_feature = Layer.rgeo_factory_for_column(:geometry).parse_wkt(cluster.cluster_centroid)
  feature = RGeo::GeoJSON::Feature.new(geom_feature, nil, { cluster_size: cluster.cluster_geometry_count.to_i })

  features << feature
end

feature_collection = RGeo::GeoJSON::FeatureCollection.new(features)
RGeo::GeoJSON.encode(feature_collection)

# BOOM! You just made some GeoJSON which is ready to be displayed on a map.
# You've also embedded the cluster_size in the GeoJSON, so you can do some
# fancy client side interaction based on cluster size. For example, you could
# make outliers (small clusters) bright red, or you could vary the size of the
# cluster centroid based on the size of cluster.
#
# Ideally, you could vary your +grid_size+ based on the user's view port.
# For example, you could set it to fixed values based on the user's zoom level.
# You could dynamically generate it based on some fraction of the user's view port bbox.

```

### Added in Version 0.0.1

This version allows for hand-coded low-level clustering via the Arel interface.

e.g.

```ruby

# Get the Arel handle for the model

arel_table = MyModel.arel_table

# Our cluster grid size.
# Smaller grid_size means more clusters.
# Larger grid_size means less clusters (cluster covers a larger area).
# See http://www.postgis.org/docs/ST_SnapToGrid.html for more info.

grid_size = 0.1

# Cluster against our model's :latlon attribute with a grid size of '0.1'.
# Return the centroid of each cluster as "cluster_centroid".

query = MyModel.select(
  arel_table.st_astext(
    arel_table.st_centroid(arel_table.st_collect(arel_table[:latlon]))
  ).as("cluster_centroid")
).group(arel_table[:latlon].st_snaptogrid(grid_size))

# Iterate over our clusters
query.all.each do |cluster|

  # print the cluster_centroid (a point) as WKT
  puts cluster["cluster_centroid"]

  # convert the WKT into a RGeo Geometry (a point)
  geographic_factory.parse_wkt(cluster["cluster_centroid")

  # ...
end

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
