# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class RolesController < ApplicationController
  before_filter :require_admin
  menu_item :admin

  verify :method => :post, :only => [ :destroy, :move ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list' unless request.xhr?
  end

  def list
    @role_pages, @roles = paginate :roles, :per_page => 25, :order => 'builtin, position'
    render :action => "list", :layout => false if request.xhr?
  end

  def new
    # Prefills the form with 'Non member' role permissions
    @role = Role.new(params[:role] || {:permissions => Role.non_member.permissions})
    if request.post? && @role.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Role.find_by_id(params[:copy_workflow_from]))
        @role.workflows.copy(copy_from)
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'list'
    end
    @permissions = @role.setable_permissions
    @roles = Role.find :all, :order => 'builtin, position'
  end

  def edit
    @role = Role.find(params[:id])
    if request.post? and @role.update_attributes(params[:role])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'list'
    end
    @permissions = @role.setable_permissions
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to :action => 'list'
  rescue
    flash[:error] = 'Ce rôle est utilisé et ne peut donc pas être supprimé'
    redirect_to :action => 'index'
  end
  
  def move
    @role = Role.find(params[:id])
    case params[:position]
    when 'highest'
      @role.move_to_top
    when 'higher'
      @role.move_higher
    when 'lower'
      @role.move_lower
    when 'lowest'
      @role.move_to_bottom
    end if params[:position]
    redirect_to :action => 'list'
  end
  
  def report    
    @roles = Role.find(:all, :order => 'builtin, position')
    @permissions = Redmine::AccessControl.permissions.select { |p| !p.public? }
    if request.post?
      @roles.each do |role|
        role.permissions = params[:permissions][role.id.to_s]
        role.save
      end
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'list'
    end
  end
end
