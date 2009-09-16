class ProjectRelation < ActiveRecord::Base

  belongs_to :project
  belongs_to :project_from, :class_name => 'Project', :foreign_key => 'project_from_id'
  belongs_to :project_to, :class_name => 'Project', :foreign_key => 'project_to_id'
  belongs_to :project_relation_type

 
  validates_presence_of :project_from, :project_to, :project_relation_type_id
  validates_numericality_of :delay, :allow_nil => true
  validates_uniqueness_of :project_to_id, :scope => :project_from_id

  def validate
    if project_from && project_to
      errors.add :project_to_id, :activerecord_error_invalid if project_from_id == project_to_id
    end
  end

  def label_for(project)
    self.project_from_id == project.id ? self.project_relation_type.relation_type : self.project_relation_type.relation_type_sym
  end

  def other_project(project)
    (self.project_from_id == project.id) ? project_to : project_from
  end

end
