class CreateProjectRelations < ActiveRecord::Migration
  def self.up
    create_table :project_relations do |t|
      t.column :project_from_id, :integer, :null => false
      t.column :project_to_id, :integer, :null => false
      t.column :project_relation_type_id, :string, :default => "", :null => false
      t.column :delay, :integer
    end
  end

  def self.down
    drop_table :project_relations
  end
end
