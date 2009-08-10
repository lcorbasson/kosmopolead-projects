class ModifyTrackerIssue < ActiveRecord::Migration
  def self.up
    change_column :issues, :tracker_id, :integer,  :null => true
  end

  def self.down
  end
end
