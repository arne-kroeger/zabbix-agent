# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook:: zabbix
# Recipe:: agent_common
#
# Copyright:: 2011, Efactures
#
# Apache 2.0
#

# Manage user and group
if platform?('windows')
  user node['zabbix']['agent']['user'] do
    not_if { node['zabbix']['agent']['user'] == 'Administrator' }
  end
else
  group node['zabbix']['agent']['group'] do
    gid node['zabbix']['agent']['gid'] if node['zabbix']['agent']['gid']
    system true
  end
  user node['zabbix']['agent']['user'] do
    shell node['zabbix']['agent']['shell']
    uid node['zabbix']['agent']['uid'] if node['zabbix']['agent']['uid']
    gid node['zabbix']['agent']['gid'] || node['zabbix']['agent']['group']
    system true
    manage_home true
  end
end

directory node['zabbix']['install_dir'] do
  unless platform_family?('windows') && node['zabbix']['agent']['user'] == 'Administrator'
    owner node['zabbix']['agent']['user']
    group node['zabbix']['agent']['group']
  end
  mode '755'
end

# Create root folders
if platform_family?('windows')
  directory node['zabbix']['etc_dir'] do
    owner node['zabbix']['agent']['user'] unless node['zabbix']['agent']['user'] == 'Administrator'
    rights :read, 'Everyone', applies_to_children: true
    recursive true
  end
  directory node['zabbix']['agent']['scripts'] do
    owner node['zabbix']['agent']['user'] unless node['zabbix']['agent']['user'] == 'Administrator'
    rights :read, 'Everyone', applies_to_children: true
    recursive true
  end
  directory node['zabbix']['agent']['include_dir'] do
    owner node['zabbix']['agent']['user'] unless node['zabbix']['agent']['user'] == 'Administrator'
    rights :read, 'Everyone', applies_to_children: true
    recursive true
    notifies :restart, 'service[zabbix-agent]'
  end
else
  directory node['zabbix']['etc_dir'] do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end
  directory node['zabbix']['agent']['scripts'] do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end
  directory node['zabbix']['agent']['include_dir'] do
    recursive true
    owner 'root'
    group 'root'
    mode '755'
    notifies :restart, 'service[' + node['zabbix']['agent']['package_name'] + ']'
  end
end

# Define zabbix owned folders
zabbix_dirs = [
  node['zabbix']['log_dir'],
]
zabbix_dirs << node['zabbix']['run_dir'] unless platform?('windows')

# Create zabbix folders
zabbix_dirs.each do |dir|
  directory dir do
    unless platform_family?('windows') && node['zabbix']['agent']['user'] == 'Administrator'
      owner node['zabbix']['agent']['user']
      group node['zabbix']['agent']['group']
    end
    mode '755'
    recursive true
    # Only execute this if zabbix can't write to it. This handles cases of
    # dir being world writable (like /tmp)
    not_if { ::File.world_writable?(dir) }
  end
end

include_recipe "zabbix-agent::install_#{node['zabbix']['agent']['install_method']}"
