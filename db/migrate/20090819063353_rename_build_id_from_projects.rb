class RenameBuildIdFromProjects < ActiveRecord::Migration
  def self.up
    rename_column :projects, :build_by, :builder_by
  end

  def self.down
  end
end
