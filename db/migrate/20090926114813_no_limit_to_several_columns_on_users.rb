class NoLimitToSeveralColumnsOnUsers < ActiveRecord::Migration
  def self.up
    change_column(:users, :mail,  :string, :default => "", :null => true)
    change_column(:users, :firstname,  :string, :default => "", :null => true)
    change_column(:users, :lastname,  :string, :default => "", :null => false)
  end

  def self.down
    change_column(:users, :mail,  :string, :limit => 30, :default => "", :null => true)
    change_column(:users, :firstname,  :string, :limit => 30, :default => "", :null => true)
    change_column(:users, :lastname,  :string, :limit => 30, :default => "", :null => false)
  end
end
