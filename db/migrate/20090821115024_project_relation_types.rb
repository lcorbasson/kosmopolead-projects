class ProjectRelationTypes < ActiveRecord::Migration
  def self.up
     create_table :project_relation_types do |t|
      t.column :type, :string
    end
  end

  def self.down
    drop_table :project_relation_types
  end
end
