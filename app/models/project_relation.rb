class ProjectRelation < ActiveRecord::Base

  belongs_to :project
  belongs_to :project_from, :class_name => 'Project', :foreign_key => 'project_from_id'
  belongs_to :project_to, :class_name => 'Project', :foreign_key => 'project_to_id'
  belongs_to :project_relation_type

  TYPE_RELATES      = "relates"
  TYPE_DUPLICATES   = "duplicates"
  TYPE_BLOCKS       = "blocks"
  TYPE_PRECEDES     = "precedes"

  TYPES = { TYPE_RELATES =>     { :name => :label_relates_to, :sym_name => :label_relates_to, :order => 1 },
            TYPE_DUPLICATES =>  { :name => :label_duplicates, :sym_name => :label_duplicated_by, :order => 2 },
            TYPE_BLOCKS =>      { :name => :label_blocks, :sym_name => :label_blocked_by, :order => 3 },
            TYPE_PRECEDES =>    { :name => :label_precedes, :sym_name => :label_follows, :order => 4 },
          }.freeze

  validates_presence_of :project_from, :project_to, :project_relation_type_id
  validates_numericality_of :delay, :allow_nil => true
  validates_uniqueness_of :project_to_id, :scope => :project_from_id

  def validate
    if project_from && project_to
      errors.add :project_to_id, :activerecord_error_invalid if project_from_id == project_to_id
    end
  end

  def label_for(project)
    TYPES[relation_type] ? TYPES[relation_type][(self.project_from_id == project.id) ? :name : :sym_name] : :unknow
  end

  def other_project(project)
    (self.project_from_id == project.id) ? project_to : project_from
  end

end
