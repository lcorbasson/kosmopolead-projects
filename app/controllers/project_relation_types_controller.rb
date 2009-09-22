class ProjectRelationTypesController < ApplicationController
  before_filter :require_admin, :require_community
  menu_item :admin

  def new
    @relation_type = ProjectRelationType.new
  end

  def create
    @relation_type = @community.project_relation_types.build(params[:project_relation_type])
    if @relation_type.save
      flash['notice'] = "Le type de relation de projet a été créé avec succès."
      redirect_to :controller => :admin, :action => :relations
    else
      # f.error_messages ne fonctionne pas... :/
      flash.now['error'] = "Le label n'est pas valide."
      render :action => 'new'
    end
  end

  def destroy
    @relation_type = @community.project_relation_types.find(params[:id])
    if @relation_type.destroy
      flash['notice'] = "Le type de relation de projet a été supprimé avec succès."
      redirect_to :controller => :admin, :action => :relations
    end
  end
  
end
