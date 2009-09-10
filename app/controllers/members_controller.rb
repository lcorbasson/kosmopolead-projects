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

class MembersController < ApplicationController
  before_filter :find_member, :except => [:create,:new]
  before_filter :find_project, :only => [:create,:new]
  before_filter :authorize,:except=>[:create,:new]

  def new
    if params[:partner_id].blank?
        @users = @project.users
      else
        @users = Partner.find(params[:partner_id]).members-@project.users
      end
      respond_to do |format|
        format.js { render(:update) {|page| page.replace_html "member_users", content_tag('select', options_from_collection_for_select(@users, 'id', 'name'), :id => 'member_user_id', :name => 'member[user_id]')} }
      end
  end


  def create    
      @project.members << Member.new(params[:member]) if request.post?
      @members = @project.members
      @member ||= @project.members.new
      @users = User.active.all
      @roles = Role.find :all, :order => 'builtin, position'
      if !params[:partner_id].blank?
        @partner = Partner.find(params[:partner_id])
        @project_partner = ProjectPartner.find(:first,:conditions=>["project_id = ? and partner_id = ?", @project.id,@partner.id])
        if !@project_partner
          ProjectPartner.create(:project_id=>@project.id,:partner_id=>@partner.id)
        end
      end
      respond_to do |format|
        format.html { redirect_to :action => 'settings', :tab => 'members', :id => @project }
        format.js { render(:update) {|page|
            page.replace_html "projects_members", :partial => 'projects/show/members'
            page.replace_html "projects_partners", :partial => 'projects/show/partners'
            page.replace_html "members-form", :partial => 'members/form',:locals=>{:display=>true}

        } }
      end   
  end


  

  
  def edit
    if request.post? and @member.update_attributes(params[:member])
  	 respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'members', :id => @project }
        format.js { render(:update) {|page| page.replace_html "tab-content-members", :partial => 'projects/settings/members'} }
      end
    end
  end



  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    respond_to do |format|
        format.js { render(:update) {|page|
            page.replace_html "projects_members", :partial => 'projects/show/members'
            page.replace_html "members-form", :partial => 'members/form',:locals=>{:display=>true}} }
    end
  end

private
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_member
    @member = Member.find(params[:id]) 
    @project = @member.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
