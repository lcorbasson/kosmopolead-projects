class ModifyProjectRelationType < ActiveRecord::Migration
  def self.up
    rename_column :project_relation_types,:type,:relation_type
  end

  def self.down
    rename_column :project_relation_types,:relation_type,:type
  end
end
