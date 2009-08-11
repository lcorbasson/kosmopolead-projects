class CreateIssueType < ActiveRecord::Migration
  def self.up
    create_table :issue_types do |t|
      t.string :name
      t.timestamp
    end

    ["STAGE", "MILESTONE", "ISSUE"].each do |type|
      IssueType.create(:name=>type)
    end

  end

  def self.down
    drop_table :issue_types
  end
end
