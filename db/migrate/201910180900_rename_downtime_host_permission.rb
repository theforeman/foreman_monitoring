# frozen_string_literal: true

class RenameDowntimeHostPermission < ActiveRecord::Migration[5.2]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Permission.where(name: 'manage_host_downtimes').update_all(name: 'manage_downtime_hosts') if table_exists?(:permissions)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    Permission.where(name: 'manage_downtime_hosts').update_all(name: 'manage_host_downtimes') if table_exists?(:permissions)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
