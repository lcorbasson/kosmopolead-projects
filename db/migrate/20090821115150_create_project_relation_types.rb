class CreateProjectRelationTypes < ActiveRecord::Migration
  def self.up
    create_table :project_relation_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :project_relation_types
  end
end
