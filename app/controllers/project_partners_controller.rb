class ProjectPartnersController < ApplicationController
  before_filter :find_project

  def new
    @project_partner = ProjectPartner.create(params[:project_partner])
     respond_to do |format|      
        format.js { render(:update) {|page| page.replace_html "projects_partners", :partial => 'projects/show/partners'} }
      end
  end

  def destroy
    @project_partner = ProjectPartner.find(params[:id])
    @project_partner.destroy
    respond_to do |format|
        format.js { render(:update) {|page| page.replace_html "projects_partners", :partial => 'projects/show/partners'} }
    end
  end


  protected
  def find_project

      @project = Project.find_by_identifier(params[:project_id])

  rescue ActiveRecord::RecordNotFound
    render_404
  end

end