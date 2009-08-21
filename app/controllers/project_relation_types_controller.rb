class ProjectRelationTypesController < ApplicationController
  menu_item :admin

  def new
    @relation_type = ProjectRelationType.new    
  end

  def create
    @relation_type = ProjectRelationType.new(params[:project_relation_type])
    if @relation_type.save
      redirect_to :controller=>:admin, :action=>:relations
    end

  end

  
end
