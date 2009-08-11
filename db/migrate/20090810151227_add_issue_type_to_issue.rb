class AddIssueTypeToIssue < ActiveRecord::Migration
  def self.up
     change_table :issues do |t|
      t.references :issue_types
     end
  end

  def self.down
    remove_column :issue_types_id
  end
end
