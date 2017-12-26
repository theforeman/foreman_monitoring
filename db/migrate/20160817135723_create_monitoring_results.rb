class CreateMonitoringResults < ActiveRecord::Migration[4.2]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :monitoring_results do |t|
      t.references :host, :null => false
      t.string :service, :null => false
      t.integer :result, :default => 0, :null => false
      t.boolean :downtime, :default => false, :null => false
      t.boolean :acknowledged, :default => false, :null => false
      t.datetime :timestamp
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
