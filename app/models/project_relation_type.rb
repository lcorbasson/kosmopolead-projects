class ProjectRelationType < ActiveRecord::Base
  belongs_to :community

  validates_presence_of :relation_type, :community

  before_destroy :destroy_project_relations

  private

  def destroy_project_relations
    @project_relations = ProjectRelation.find(:all,:conditions=>["project_relation_type_id = ?",self.id])
    @project_relations.each do |relation|
      relation.destroy
    end
  end

end
