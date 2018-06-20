name             'storage'
maintainer       'Jeff Byrnes'
maintainer_email 'jeff@darksky.net'
license          'Apache-2.0'
description      'Installs/Configures storage'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '6.0.1'
chef_version     '>= 12.11', '< 15.0.0'

supports 'ubuntu', '>= 12.04'

depends 'ohai'
depends 'aws', '~> 4.0'
