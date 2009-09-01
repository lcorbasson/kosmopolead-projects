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
  before_filter :find_project,:except=>[:index]
  before_filter :read_authorize, :except => [:destroy,:index,:create]
  before_filter :delete_authorize, :only => [:destroy]
  
  verify :method => :post, :only => :destroy


  def index
     @project = Project.find_by_identifier(params[:project_id])
     @containers = [ Project.find(@project.id, :include => :file_attachments)]
     @containers += @project.versions.find(:all, :include => :file_attachments)
     render :layout=>false
  end

  def create
    @file = FileAttachment.new(params[:file_attachment])
    @file.container_id = @project.id
    @file.container_type = "project"
    @file.save
    respond_to do |format|  
      format.js { render(:update) {|page| page.replace_html "files_index", :partial => 'file_attachments/index'} }
    end
    
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
    if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
      @attachment.increment_download
    end
    
    # images are sent inline
    send_file @attachment.diskfile, :filename => filename_for_content_disposition(@attachment.filename),
                                    :type => @attachment.content_type, 
                                    :disposition => (@attachment.image? ? 'inline' : 'attachment')
   
  end
  
  def destroy
    # Make sure association callbacks are called
    @attachment.container.attachments.delete(@attachment)
    redirect_to :back
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
