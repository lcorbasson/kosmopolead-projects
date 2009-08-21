class ProjectRelationsController < ApplicationController
  before_filter :find_project

  def new
    @relation = ProjectRelation.new()
    @relation.project_from = @project
    @relation.project_to = Project.find(params[:relation][:project_to_id])
    @relation_type = ProjectRelationType.find(params[:relation][:project_relation_type_id])
    @relation.project_relation_type_id = @relation_type.id
    @relation.save if request.post?
    respond_to do |format|
      format.html { redirect_to :controller => 'projects', :action => 'show', :id => @project }
      format.js do
        render :update do |page|
          
          page.replace_html "relations", :partial => 'projects/relations'
          if @relation.errors.empty?
            page << "$('relation_delay').value = ''"
            page << "$('relation_issue_to_id').value = ''"
          end
        end
      end
    end
  end

  def destroy
    relation = IssueRelation.find(params[:id])
    if request.post? && @issue.relations.include?(relation)
      relation.destroy
      @issue.reload
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js { render(:update) {|page| page.replace_html "relations", :partial => 'issues/relations'} }
    end
  end

  private
  def find_project
    @project = Project.find(params[:project_id])

  rescue ActiveRecord::RecordNotFound
    render_404
  end

end