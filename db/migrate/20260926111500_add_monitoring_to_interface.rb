# frozen_string_literal: true

class AddMonitoringToInterface < ActiveRecord::Migration[6.0]
  def up
    add_column :nics, :monitoring, :boolean, :default => false, :null => false

    Nic::Managed.reset_column_information
    Nic::Managed.where(:primary => true).update_all(:monitoring => true)
  end

  def down
    remove_column :nics, :monitoring
  end
end
