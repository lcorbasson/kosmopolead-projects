class AddIsDefaultToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :is_default, :int
  end

  def self.down
    remove_column :roles, :is_default
  end
end
