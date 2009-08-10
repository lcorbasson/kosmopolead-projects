class CreateTypeIssues < ActiveRecord::Migration
  def self.up
     create_table :issue_types, :force => true do |t|     
      t.string :name
    end
  end

  def self.down
    drop_table :issue_types
  end
end
