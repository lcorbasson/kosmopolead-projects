class Community < ActiveRecord::Base

  has_many :community_memberships
  has_many :users, :through => :community_memberships
  has_many :custom_fields
  has_many :project_relation_types
  has_many :projects
  has_many :queries
  has_many :partners

  acts_as_tree :order => "lastname"

  validates_presence_of :name

  cattr_accessor(:current)
end
