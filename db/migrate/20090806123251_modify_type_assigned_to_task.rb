class ModifyTypeAssignedToTask < ActiveRecord::Migration
  def self.up
    change_column :issues, :assigned_to_id, :string
  end

  def self.down
  end
end
