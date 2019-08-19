name              'zabbix-agent'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs/Configures Zabbix Agent'
source_url        'https://github.com/sous-chefs/zabbix-agent'
issues_url        'https://github.com/sous-chefs/zabbix-agent/issues'
version           '0.14.1'
chef_version      '>= 13'

%w(ubuntu redhat centos debian windows).each do |os|
  supports os
end

depends 'apt'
depends 'yum'
depends 'build-essential'
depends 'chocolatey'
