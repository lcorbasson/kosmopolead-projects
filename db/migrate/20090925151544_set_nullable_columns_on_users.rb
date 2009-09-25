class SetNullableColumnsOnUsers < ActiveRecord::Migration
  def self.up
    change_column(:users, :mail,  :string, :limit => 30, :default => "", :null => true)
    change_column(:users, :firstname,  :string, :limit => 30, :default => "", :null => true)
  end

  def self.down
    change_column(:users, :mail,  :string, :limit => 30, :default => "", :null => false)
    change_column(:users, :firstname,  :string, :limit => 30, :default => "", :null => false)
  end
end
