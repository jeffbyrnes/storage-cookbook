name             'storage'
maintainer       'Jeff Byrnes'
maintainer_email 'thejeffbyrnes@gmail.com'
license          'Apache-2.0'
description      'Installs/Configures storage'
version          '8.0.0'
chef_version     '>= 13.0', '< 16.0.0'

source_url       'https://github.com/jeffbyrnes/storage-cookbook'
issues_url       'https://github.com/jeffbyrnes/storage-cookbook/issues'

supports 'ubuntu', '>= 16.04'

depends 'ohai'
depends 'aws', '~> 8.0'
