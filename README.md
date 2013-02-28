# RPClustering::RGeo::ActiveRecord

A RGeo PostGIS extension to provide Active Record (Model) clustering functionality.

The intention is that this Gem will eventually provide abstracted methods for
both "on the fly" clustering, as well as cached clustering (including associated generators).

If you find a problem with this Gem, please don't hesitate to raise an [issue](https://github.com/robertpyke/rp_clustering-rgeo-activerecord/issues).

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
        arel_table.st_centroid(arel_table.st_collect(attr))
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
