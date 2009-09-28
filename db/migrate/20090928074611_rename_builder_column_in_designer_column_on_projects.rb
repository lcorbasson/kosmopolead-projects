class RenameBuilderColumnInDesignerColumnOnProjects < ActiveRecord::Migration
  def self.up
    rename_column :projects, :builder_by, :designer_id
  end

  def self.down
    rename_column :projects, :designer_id, :builder_by
  end
end
