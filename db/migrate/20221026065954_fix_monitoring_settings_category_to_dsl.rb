# frozen_string_literal: true

class FixMonitoringSettingsCategoryToDsl < ActiveRecord::Migration[6.0]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Setting.where(category: 'Setting::Monitoring').update_all(category: 'Setting')
    # rubocop:enable Rails/SkipsModelValidations
  end
end
