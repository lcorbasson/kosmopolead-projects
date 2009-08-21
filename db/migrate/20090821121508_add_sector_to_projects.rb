class AddSectorToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :sector, :text
  end

  def self.down
    remove_column :projects, :sector
  end
end
