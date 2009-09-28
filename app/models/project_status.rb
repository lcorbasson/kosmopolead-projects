class ProjectStatus < ActiveRecord::Base

  has_many :projects
  belongs_to :community

  # -- validations

  validates_presence_of :status_label, :community
  validates_uniqueness_of :status_label, :scope => [:community_id]
  validates_length_of :status_label, :maximum => 30
  validates_format_of :status_label, :with => /^[\w\s\'\-]*$/i

  # -- Gestion des positions

  acts_as_list


  
end