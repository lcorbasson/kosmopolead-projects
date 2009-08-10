class CreateIssueTypes < ActiveRecord::Migration
  def self.up
    create_table :issue_types do |t|
      t.timestamps
    end

    IssueType.allow_types.each do |type|
      IssueType.create(:name=>type)
    end
    
  end

  def self.down
    drop_table :issue_types
  end
end
