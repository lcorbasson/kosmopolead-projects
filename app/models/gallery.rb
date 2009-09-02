class Gallery < ActiveRecord::Base

  # -- relations
  
  has_many :photos
  belongs_to :project
end
