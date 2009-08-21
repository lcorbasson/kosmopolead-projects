class AddResourcesToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :resources, :text
  end

  def self.down
    remove_column :issues, :resources
  end
end
