class CreateMonitoringResults < ActiveRecord::Migration
  def change
    create_table :monitoring_results do |t|
      t.references :host, :null => false
      t.string :service, :null => false
      t.integer :result, :default => 0, :null => false
      t.boolean :downtime, :default => false, :null => false
      t.boolean :acknowledged, :default => false, :null => false
      t.datetime :timestamp
    end
  end
end
