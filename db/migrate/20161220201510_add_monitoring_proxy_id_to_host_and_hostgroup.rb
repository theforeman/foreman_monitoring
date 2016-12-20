class AddMonitoringProxyIdToHostAndHostgroup < ActiveRecord::Migration
  def self.up
    add_column :hosts, :monitoring_proxy_id, :integer
    add_column :hostgroups, :monitoring_proxy_id, :integer
  end

  def self.down
    remove_column :hosts, :monitoring_proxy_id
    remove_column :hostgroups, :monitoring_proxy_id
  end
end
