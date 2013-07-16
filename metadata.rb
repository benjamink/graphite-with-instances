name             'graphite'
maintainer       'AWeber Communications, Inc.'
maintainer_email 'brianj@aweber.com'
license          'Apache 2.0'
description      'Installs/Configures graphite'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.4'

depends  'python'
depends  'cron'
depends  'apache2'
depends  'afw'
depends  'logrotate'
supports 'ubuntu'
