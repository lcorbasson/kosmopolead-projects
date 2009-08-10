class AddParentIdAndTasksCountToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :parent_id, :integer
    add_column :issues, :issues_count, :integer
  end

  def self.down
    remove_column :issues, :parent_id
    remove_column :issues, :issues_count
  end
end
