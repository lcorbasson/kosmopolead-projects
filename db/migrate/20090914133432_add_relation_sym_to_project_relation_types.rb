class AddRelationSymToProjectRelationTypes < ActiveRecord::Migration
  def self.up
    add_column :project_relation_types, :relation_type_sym, :string
  end

  def self.down
    remove_column :project_relation_types, :relation_type_sym
  end
end
