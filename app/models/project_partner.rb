class ProjectPartner < ActiveRecord::Base

  # Relations
  belongs_to :project
  belongs_to :partner

end
