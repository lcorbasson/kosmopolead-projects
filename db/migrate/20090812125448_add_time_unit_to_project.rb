class AddTimeUnitToProject < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.references :time_units
    end
  end

  def self.down
    remove_column :unit_times_id
  end
end
