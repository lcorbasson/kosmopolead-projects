class RenameCommunityUserIdToCommunityIdOnCommunityMemberships < ActiveRecord::Migration
  def self.up
    rename_column(:community_memberships, :community_user_id, :community_id)
  end

  def self.down
    rename_column(:community_memberships, :community_id, :community_user_id)
  end
end
