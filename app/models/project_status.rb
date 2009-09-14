class ProjectStatus < ActiveRecord::Base

  # -- validations

  validates_presence_of :status_label
  validates_uniqueness_of :status_label
  validates_length_of :status_label, :maximum => 30
  validates_format_of :status_label, :with => /^[\w\s\'\-]*$/i

  # -- Gestion des positions

  acts_as_list

  
end