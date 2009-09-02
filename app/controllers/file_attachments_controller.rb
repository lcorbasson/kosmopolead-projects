# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
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

class FileAttachmentsController < ApplicationController
  before_filter :find_project

  
  verify :method => :post, :only => :destroy


  def index    
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      @file_attachments = @issue.file_attachments     
    else 
        @project = Project.find_by_identifier(params[:project_id])
      @file_attachments = @project.file_attachments
    end
     render :layout=>false
  end

  def create
    @file_attachment = FileAttachment.new(params[:file_attachment])
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      @file_attachment.container_id = @issue.id
      @file_attachment.container_type = "issue"
    else
      @project = Project.find_by_identifier(params[:project_id])
      @file_attachment.container_id = @project.id
      @file_attachment.container_type = "project"      
    end
    @file_attachment.author_id = User.current.id
    @file_attachment.save
    respond_to do |format|  
      format.js { render(:update) {|page|
          if params[:project_id]
              page.replace_html "files_index", :partial => 'file_attachments/index',:locals=>{:file_attachments=>@project.file_attachments}
          else
              page.replace_html "files_index", :partial => 'file_attachments/index',:locals=>{:file_attachments=>@issue.file_attachments}
          end
        } }
    end
    
  end

  def new
    test = params[:file_attachment]
    @file_attachment = FileAttachment.new
    @file_attachment.container_id = params[:project_id]
    if params[:issue_id]
       @file_attachment.container_type = "issue"
       @issue = Issue.find(params[:issue_id])
       @file_attachment.container_id = @issue.id
    else 
       @file_attachment.container_type = "project"
       @project = Project.find_by_identifier(params[:project_id])
       @file_attachment.container_id = @project.id
    end
    render :layout=>false
  end


  def show
    if @attachment.is_diff?
      @diff = File.new(@attachment.diskfile, "rb").read
      render :action => 'diff'
    elsif @attachment.is_text?
      @content = File.new(@attachment.diskfile, "rb").read
      render :action => 'file'
    elsif
      download
    end
  end
  
  def download
    @attachment = FileAttachment.find(params[:id])
    if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      @attachment.increment_download
    end
    
    # images are sent inline
    send_file @attachment.file.path, :filename => filename_for_content_disposition(@attachment.file_file_name),
                                    :type => @attachment.file_content_type,
                                    :disposition => 'attachment'
   
  end
  
  def destroy
    # Make sure association callbacks are called
    @attachment = FileAttachment.find(params[:id])
    @attachment.destroy
    respond_to do |format|
        format.js {
          render(:update) {|page|
                if @attachment.container_type == "project"
                    @project = Project.find(@attachment.container_id)
                    page.replace_html "files_index", :partial => 'file_attachments/index',:locals=>{:file_attachments=>@project.file_attachments}
                else
                  if @attachment.container_type == "issue"
                    @issue = Issue.find(@attachment.container_id)
                    page.replace_html "files_index", :partial => 'file_attachments/index',:locals=>{:file_attachments=>@issue.file_attachments}
                  end
                end
               }
         }
     end   
  rescue ::ActionController::RedirectBackError
    redirect_to :controller => 'projects', :action => 'show', :id => @project
  end
  
private
  def find_project    
    @project = Project.find_by_identifier(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def read_authorize
    @attachment.visible? ? true : deny_access
  end
  
  def delete_authorize
    @attachment.deletable? ? true : deny_access
  end
end
