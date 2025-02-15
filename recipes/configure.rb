# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook:: zabbix
# Recipe:: configure
#
# Copyright:: 2011, Efactures
#
# Apache 2.0
#
include_recipe 'zabbix-agent::install'

# Install configuration
template 'zabbix_agentd.conf' do
  path node['zabbix']['agent']['config_file']
  source 'zabbix_agentd.conf.erb'
  unless platform_family?('windows')
    owner 'root'
    group 'root'
    mode '644'
  end
  variables config: node['zabbix']['agent']['conf']
  notifies :restart, 'service[' + node['zabbix']['agent']['package_name'] + ']'
end

# Install optional additional agent config file containing UserParameter(s)
template 'user_params.conf' do
  path node['zabbix']['agent']['userparams_config_file']
  source 'user_params.conf.erb'
  unless platform_family?('windows')
    owner 'root'
    group 'root'
    mode '644'
  end
  notifies :restart, 'service[' + node['zabbix']['agent']['package_name'] + ']'
  not_if { node['zabbix']['agent']['user_parameter'].empty? }
end
