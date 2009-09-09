class CommunityMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :community_user

  ROLES = ['user', 'admin']

  validates_uniqueness_of :user_id, :scope => :community_user_id
  validates_inclusion_of :role, :in => ROLES

  before_validation_on_create do |m|
    m.role ||= 'user'
  end

  def admin?
    role == 'admin'
  end

  def user?
    role == 'user'
  end
end
