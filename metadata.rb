name             'storage'
maintainer       'Jeff Byrnes'
maintainer_email 'jeff@darksky.net'
license          'Apache-2.0'
description      'Installs/Configures storage'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '6.0.1'
chef_version     '>= 13.0', '< 15.0.0'

source_url       'https://github.com/darkskyapp/storage-cookbook'
issues_url       'https://github.com/darkskyapp/storage-cookbook/issues'

supports 'ubuntu', '>= 16.04'

depends 'ohai'
depends 'aws', '~> 7.4'
