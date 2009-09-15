class ProjectRelationType < ActiveRecord::Base
  belongs_to :community

  validates_presence_of :relation_type, :community
end
