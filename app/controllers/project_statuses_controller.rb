class ProjectStatusesController < ApplicationController
  before_filter :require_admin, :require_community
  menu_item :admin

  def index
    list
    render :action => 'list' unless request.xhr?
  end

  def list
    @project_statuses = @community.project_statuses
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    @project_status = @community.project_statuses.build
  end

  def create
    @project_status = @community.project_statuses.build(params[:project_status])
    if @project_status.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @project_status = @community.project_statuses.find(params[:id])
  end

  def update
    @project_status = @community.project_statuses.find(params[:id])
    if @project_status.update_attributes(params[:project_status])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end
  
  def move
    @project_status = @community.project_statuses.find(params[:id])
    case params[:position]
    when 'highest'
      @project_status.move_to_top
    when 'higher'
      @project_status.move_higher
    when 'lower'
      @project_status.move_lower
    when 'lowest'
      @project_status.move_to_bottom
    end if params[:position]
    redirect_to :action => 'list'
  end

  def destroy
    @project_status = @community.project_statuses.find(params[:id])    
    if @projects_with_status = Project.find(:all,:conditions=>["status_id = ?",@project_status.id])
      flash[:error] = l(:cant_delete_project_status_because_relations)
    else
      if @project_status.destroy
        flash[:notice] = l(:notice_successful_update)
      else
        flash[:error] = l(:unable_to_delete_project_status)
      end
    end
    redirect_to :action => 'list' 
  end  	


end