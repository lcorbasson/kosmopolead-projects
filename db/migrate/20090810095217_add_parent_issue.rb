class AddParentIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :parent_id, :integer
  end

  def self.down
    remove_column :parent_id
  end
end
