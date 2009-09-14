class ProjectRelationType < ActiveRecord::Base

  before_destroy :destroy_project_relations

  private

  def destroy_project_relations
    @project_relations = ProjectRelation.find(:all,:conditions=>["project_relation_type_id = ?",self.id])
    @project_relations.each do |relation|
      relation.destroy
    end
  end

end
