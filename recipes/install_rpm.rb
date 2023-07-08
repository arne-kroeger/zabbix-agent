remote_file Chef::Config[:file_cache_path] + '/zabbix-repo.rpm' do
  source node['zabbix']['agent']['rpm']
  action :create
end

rpm_package 'zabbix' do
  source Chef::Config[:file_cache_path] + '/zabbix-repo.rpm'
  action :install
end

package node['zabbix']['agent']['package_name'] do
  action :upgrade
end
