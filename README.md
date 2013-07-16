DESCRIPTION:
------------

Installs and configures Graphite http://graphite.wikidot.com/

REQUIREMENTS:
-------------

Ubuntu 10.04 (Lucid)

ATTRIBUTES:
-----------

node[:graphite][:password] sets the default password for graphite
"root" user.

USAGE:
------

recipe[graphite] should build a stand-alone Graphite installation.

recipe[graphite::ganglia] integrates with Ganglia. You'll want at
least one monitor node (i.e. recipe[ganglia]) node to be running
to use it.

MULTIPLE CACHES & RELAYS:
-------------------------

In order to run multiple caches & relays, certain attributes need to be set to configure each cache or relay.  The following shows a typical cache configuration with the required attributes.  Additional configuration attributes can be defined simply by adding them to the hash (see the Graphite documentation or carbon.conf.example for documentation of the various cache & relay attributes).  **NOTE**, these attributes **must** be defined as `override_attributes` or they will not populate correctly.

  override_attributes(
    'graphite' => {
      'carbon' => {
        'caches' => {
          'a' => {
            'line_receiver_port' => '2031',
            'line_receiver_interface' => '0.0.0.0',
            'pickle_receiver_port' => '2041',
            'pickle_receiver_interface' => '0.0.0.0',
            'cache_query_port' => '7021',
            'cache_query_interface' => '0.0.0.0'
          }
        }
      }
    }
  )

Adding relays is very similar:

  override_attributes(
    'graphite' => {
      'carbon' => {
        'relays' => {
          'a' => {
            'relay_method' => 'consistent-hashing',
            'replication_factor' => '2',
            'line_receiver_interface' => '0.0.0.0',
            'line_receiver_port' => '2003',
            'pickle_receiver_interface' => '0.0.0.0',
            'pickle_receiver_port' => '2004',
            'destinations' => 'graphite_hosts'
          }
        }
      }
    }
  )

Note that in the above relay instance block, the `destinations` attribute includes a special `graphite_hosts` value.  This attribute will be converted into a search result in the `carbon.rb` recipe automatically & populated appropriately.

CAVEATS:
--------

Ships with two default schemas, stats.* (for Etsy's statsd) and a
catchall that matches anything. The catchall retains minutely data for
13 months, as in the default config. stats retains data every 10 seconds
for 6 hours, every minute for a week, and every 10 minutes for 5 years.
