class Community < ActiveRecord::Base

  has_many :community_memberships
  has_many :users, :through => :community_memberships
  has_many :custom_fields
  has_many :project_relation_types
  has_many :projects
  has_many :queries
  has_many :partners
  has_many :activity_sectors
  has_many :project_statuses

  acts_as_tree :order => "lastname"

  validates_presence_of :name

  cattr_accessor(:current)

  def activity_sector_translations(locale)
    activity_sectors.map{|a| a.activity_sector_translations.reject{|t| t.local != locale.to_s } }.flatten
  end
end
