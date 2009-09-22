class ModifyIsPublicProjects < ActiveRecord::Migration
  def self.up
    change_column(:projects, :is_public,  :boolean, :default => false, :null => false)
  end

  def self.down
    change_column(:projects, :is_public,  :boolean, :default => true, :null => false)
  end
end
