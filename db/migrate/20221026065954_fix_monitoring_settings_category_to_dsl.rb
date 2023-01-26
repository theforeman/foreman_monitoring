# frozen_string_literal: true

class FixMonitoringSettingsCategoryToDsl < ActiveRecord::Migration[6.0]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Setting.where(category: 'Setting::Monitoring').update_all(category: 'Setting') if column_exists?(:settings, :category)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
