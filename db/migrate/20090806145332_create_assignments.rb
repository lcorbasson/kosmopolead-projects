class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments, :force => true do |t|
      t.references :issue
      t.references :user
    end
  end

  def self.down
    drop_table :assignments    
  end
end
