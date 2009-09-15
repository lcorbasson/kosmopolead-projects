class AddCommunityIdToMany < ActiveRecord::Migration
  def self.up
    add_column :projects, :community_id, :integer
    add_column :project_relation_types, :community_id, :integer
    add_column :partners, :community_id, :integer
    add_column :custom_fields, :community_id, :integer
    add_column :queries, :community_id, :integer
    add_column :activity_sectors, :community_id, :integer

    add_index :projects, :community_id
    add_index :project_relation_types, :community_id
    add_index :partners, :community_id
    add_index :custom_fields, :community_id
    add_index :queries, :community_id
    add_index :activity_sectors, :community_id
  end

  def self.down
    remove_column :projects, :community_id
    remove_column :project_relation_types, :community_id
    remove_column :partners, :community_id
    remove_column :custom_fields, :community_id
    remove_column :queries, :community_id
    remove_column :activity_sectors, :community_id
  end
end
