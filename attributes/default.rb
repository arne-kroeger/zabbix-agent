#
# Cookbook:: zabbix
# Attributes:: default

# Directories
default['zabbix']['etc_dir'] = if platform_family?('windows')
                                 ::File.join(ENV['PROGRAMDATA'], 'zabbix')
                               else
                                 '/etc/zabbix'
                               end
default['zabbix']['agent']['include_dir']            = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.d')
default['zabbix']['agent']['config_file']            = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.conf')
default['zabbix']['agent']['userparams_config_file'] = ::File.join(node['zabbix']['agent']['include_dir'], 'user_params.conf')
default['zabbix']['agent']['pid_file']               = '/var/run/zabbix/zabbix_agentd.pid'

if platform?('windows')
  default['zabbix']['install_dir']      = node['zabbix']['etc_dir']
  default['zabbix']['log_dir']          = ::File.join(node['zabbix']['etc_dir'], 'log')
  default['zabbix']['agent']['scripts'] = ::File.join(node['zabbix']['etc_dir'], 'scripts')
else
  default['zabbix']['install_dir']      = '/opt/zabbix'
  default['zabbix']['lock_dir']         = '/var/lock/subsys'
  default['zabbix']['log_dir']          = '/var/log/zabbix'
  default['zabbix']['run_dir']          = '/var/run/zabbix'
  default['zabbix']['agent']['scripts'] = '/etc/zabbix/scripts'
end

default['zabbix']['agent']['package_name']      = 'zabbix-agent2'
default['zabbix']['agent']['version']           = '6.4-1'
default['zabbix']['agent']['base-version']      = '6.4'
default['zabbix']['agent']['servers']           = ['zabbix']
default['zabbix']['agent']['servers_active']    = ['zabbix']

# primary config options
if platform?('windows')
  default['zabbix']['agent']['user']         = 'Administrator'
  default['zabbix']['agent']['group']        = 'Administrators'
else
  default['zabbix']['agent']['user']         = 'zabbix'
  default['zabbix']['agent']['group']        = node['zabbix']['agent']['user']
end
default['zabbix']['agent']['timeout']        = '3'
default['zabbix']['agent']['listen_port']    = '10050'
default['zabbix']['agent']['interfaces']     = ['zabbix_agent']
default['zabbix']['agent']['jmx_port']       = '10052'
default['zabbix']['agent']['snmp_port']      = '161'
default['zabbix']['agent']['install_method'] = 'package'
default['zabbix']['agent']['shell']          = '/bin/bash'
default['zabbix']['agent']['user_parameter'] = []

# zabbix_agent.conf file set to documented defaults
default['zabbix']['agent']['conf']['Alias'] = nil
unless platform?('windows')
  default['zabbix']['agent']['conf']['AllowRoot'] = '0'
end
default['zabbix']['agent']['conf']['BufferSend']  = '5'
default['zabbix']['agent']['conf']['BufferSize']  = '100'
default['zabbix']['agent']['conf']['DebugLevel']  = '3'
# default['zabbix']['agent']['conf']['EnableRemoteCommands'] = '0'
default['zabbix']['agent']['conf']['EnableRemoteCommands'] = '1'
default['zabbix']['agent']['conf']['HostMetadata'] = nil
default['zabbix']['agent']['conf']['Hostname']     = nil # defaults to HostnameItem
# default['zabbix']['agent']['conf']['HostnameItem'] = nil # set by system.hostname
unless platform?('windows')
  default['zabbix']['agent']['conf']['HostnameItem'] = 'system.run[hostname -f]'
end
# default['zabbix']['agent']['conf']['Include']  = nil #default
default['zabbix']['agent']['conf']['Include']      = ::File.join(default['zabbix']['agent']['include_dir'], '*.conf')
default['zabbix']['agent']['conf']['ListenIP']     = '0.0.0.0'
default['zabbix']['agent']['conf']['ListenPort']   = '10050'
unless platform?('windows')
  default['zabbix']['agent']['conf']['LoadModule']   = nil
end
default['zabbix']['agent']['conf']['LogType']      = 'system'
default['zabbix']['agent']['conf']['LogFile']      = nil
default['zabbix']['agent']['conf']['LogFileSize']  = '1'
default['zabbix']['agent']['conf']['LogRemoteCommands']  = '0'
default['zabbix']['agent']['conf']['MaxLinesPerSecond']  = '100'
if platform?('windows')
  default['zabbix']['agent']['conf']['PerfCounter'] = nil
end
unless platform?('windows')
  # default['zabbix']['agent']['conf']['PidFile']  = '/tmp/zabbix_agentd.pid'
  default['zabbix']['agent']['conf']['PidFile'] = '/var/run/zabbix/zabbix_agentd.pid'
end
default['zabbix']['agent']['conf']['RefreshActiveChecks'] = '120'
# default['zabbix']['agent']['conf']['Server']  = nil #default
default['zabbix']['agent']['conf']['Server']       = 'zabbix'
default['zabbix']['agent']['conf']['ServerActive'] = nil
default['zabbix']['agent']['conf']['SourceIP']     = nil
default['zabbix']['agent']['conf']['StartAgents']  = '3'
default['zabbix']['agent']['conf']['Timeout']      = '3'
default['zabbix']['agent']['conf']['UnsafeUserParameters'] = '0'
unless platform?('windows')
  if node['zabbix']['agent']['version'] =~ /2\.4\..*/
    default['zabbix']['agent']['conf']['User'] = default['zabbix']['agent']['user']
  end
end
# default['zabbix']['agent']['conf']['UserParameter'] = nil # favor user_parameter in seperate included file

# source install
default['zabbix']['agent']['configure_options'] = ['--with-libcurl']

download_url = 'http://downloads.sourceforge.net/project/zabbix/'
branch       = 'ZABBIX%20Latest%20Stable'
version      = node['zabbix']['agent']['version']
tar          = "zabbix-#{version}.tar.gz"
default['zabbix']['agent']['arch'] = 'x86_64'
default['zabbix']['agent']['source_url'] = "#{download_url}/#{branch}/#{version}/#{tar}"
default['zabbix']['agent']['tar_file'] = tar
default['zabbix']['agent']['rpm'] = "https://repo.zabbix.com/zabbix/#{node['zabbix']['agent']['base-version']}/rhel/#{node['platform_version'].to_i}/#{default['zabbix']['agent']['arch']}/zabbix-release-#{node['zabbix']['agent']['version']}.el#{node['platform_version'].to_i}.noarch.rpm"

# package install
case node['platform_family']
when 'debian'
  default['zabbix']['agent']['package']['repo_uri'] = "http://repo.zabbix.com/zabbix/3.0/#{node['platform']}/"
  default['zabbix']['agent']['package']['repo_key'] = 'http://repo.zabbix.com/zabbix-official-repo.key'
when 'rhel'
  default['zabbix']['agent']['package']['repo_uri'] = 'http://repo.zabbix.com/zabbix/3.0/rhel/$releasever/$basearch/'
  default['zabbix']['agent']['package']['repo_key'] = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
when 'amazon'
  # current Amazon AMI based on RHEL6 at the moment
  default['zabbix']['agent']['package']['repo_uri'] = 'http://repo.zabbix.com/zabbix/3.0/rhel/6/$basearch/'
  default['zabbix']['agent']['package']['repo_key'] = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
when 'fedora'
  default['zabbix']['agent']['package']['repo_uri'] = 'http://repo.zabbix.com/zabbix/3.0/rhel/7/$basearch/'
  default['zabbix']['agent']['package']['repo_key'] = 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
end

# prebuild install
prebuild_url = 'https://www.zabbix.com/downloads/'
arch = node['kernel']['machine'] == 'x86_64' ? 'amd64' : 'i386'
default['zabbix']['agent']['prebuild_file'] = "zabbix_agent-#{version}-linux-3.0-#{arch}-static.tar.gz"

default['zabbix']['agent']['prebuild_url']  = "#{prebuild_url}#{version}/zabbix_agent-#{version}-linux-3.0-#{arch}-static.tar.gz"
default['zabbix']['agent']['checksum'] = 'bf2ebb48fbbca66418350f399819966e'

# auto-regestration
default['zabbix']['agent']['groups'] = ['chef-agent']

case node['platform_family']
when 'fedora', 'rhel', 'debian'
  default['zabbix']['agent']['init_style'] = 'systemd'
when 'windows'
  default['zabbix']['agent']['init_style'] = 'windows'
end
