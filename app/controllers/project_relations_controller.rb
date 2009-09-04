class ProjectRelationsController < ApplicationController
  before_filter :find_project
  
  def create
    @relation = ProjectRelation.new(params[:project_relation])
    @relation.project_from = @project
    @relation.project_to = Project.find(params[:project_relation][:project_to_id])
    @relation_type = ProjectRelationType.find(params[:project_relation][:project_relation_type_id])
    @relation.project_relation_type_id = @relation_type.id
    if @relation.save
      @relation = ProjectRelation.new
      respond_to do |format|
        format.html {}
        format.js { 
          render(:update) {|page| page.replace_html "relations", :partial => 'project_relations/index'}
        }
      end
    end
  end

  def destroy
     relation = ProjectRelation.find(params[:id])
     @project = relation.project_from   
     relation.destroy
     @relation = ProjectRelation.new
    respond_to do |format|    
      format.js { render(:update) {|page| page.replace_html "relations", :partial => 'projects/relations'} }
    end
  end

  private
  def find_project
   if params[:project_id].is_a?(Integer)
      @project = Project.find(params[:project_id])
    else
      @project = Project.find_by_identifier(params[:project_id])
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

end