class Gallery < ActiveRecord::Base

  # -- relations
  
  has_many :photos
end
