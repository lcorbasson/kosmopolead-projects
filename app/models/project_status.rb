class ProjectStatus < ActiveRecord::Base

  # -- validations

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 30
  validates_format_of :name, :with => /^[\w\s\'\-]*$/i

  # -- Gestion des positions

  acts_as_list

  
end