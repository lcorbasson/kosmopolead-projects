class AddCommunityIdToProjectStatuses < ActiveRecord::Migration
  def self.up
    add_column :project_statuses, :community_id, :integer
  end

  def self.down
    remove_column :project_statuses, :community_id
  end
end
