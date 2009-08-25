# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
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

class ProjectsController < ApplicationController
  menu_item :projects,:only=>[:show]
 
 
  menu_item :activity, :only => :activity
  menu_item :roadmap, :only => :roadmap
  menu_item :files, :only => [:list_files, :add_file]
  menu_item :settings, :only => :settings

  
  before_filter :find_project, :except => [ :tags_json, :index, :list, :add, :activity ]


  before_filter :find_optional_project, :only => :activity
  before_filter :authorize, :except => [ :tags_json,:index, :list, :add, :archive, :unarchive, :destroy, :activity ]
  before_filter :require_admin, :only => [ :add, :archive, :unarchive, :destroy ]
  accept_key_auth :activity
  
  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper   
  helper :issues
  helper IssuesHelper
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  include ProjectsHelper
  
  # Lists visible projects
  def index
    @projects = Project.find :all,
                            :conditions => Project.visible_by(User.current),
                            :include => :parent
   @project = @projects.first
   unless @project.nil?
        find_files
       @members = @project.members
       @subprojects = @project.children.find(:all, :conditions => Project.visible_by(User.current))
       @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
       @trackers = @project.rolled_up_trackers
   if @projects.size>0
     @project = @projects.first
     find_files
    @members = @project.members
    @subprojects = @project.children.find(:all, :conditions => Project.visible_by(User.current))
    @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    @trackers = @project.rolled_up_trackers
    @gantt = Redmine::Helpers::Gantt.new(params)
    retrieve_query
    if @query.valid?     
      events = @project.stages(:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?)) and start_date is not null) AND issues.parent_id is null])", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to])

      @gantt.events = events
    end
   end
    completed_percent
    find_gallery
       respond_to do |format|
          format.html {
#            @project_tree = projects.group_by {|p| p.parent || p}
#            @project_tree.keys.each {|p| @project_tree[p] -= [p]}
       }
          format.atom {
            render_feed(projects.sort_by(&:created_on).reverse.slice(0, Setting.feeds_limit.to_i),
                                      :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
          }
          
        end
  end
  end
  
  # Add a new project
  def add
    @tags = Tags.all
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @trackers = Tracker.all
    @root_projects = Project.find(:all,
                                  :conditions => "status = #{Project::STATUS_ACTIVE}",
                                  :order => 'name')
    @project = Project.new(params[:project])

    @time_units = TimeUnit.find(:all)

    @users = User.find(:all)
    if !params[:project]
      @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
      @project.trackers = Tracker.all
      @project.is_public = Setting.default_projects_public?
      @project.enabled_module_names = Redmine::AccessControl.available_project_modules
      respond_to do |format|
        format.html {}
        format.js {
           render :update do |page|
              page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/add')}');"
           end
        }
      end
    else
      @project.tag_list = ''
      if select_tags =  params[:tags]
        select_tags.each do |tag|
          @project.tag_list << tag
        end
      end
      @project.enabled_module_names = params[:enabled_modules]
      if @project.save
        flash[:notice] = l(:notice_successful_create)
        redirect_to :controller => 'issues', :action => 'index',:project_id=>@project.id
      end
    end
    
    
  end
	
  # Show @project
  def show
    if params[:jump]
      # try to redirect to the requested menu item
      redirect_to_project_menu_item(@project, params[:jump]) && return
    end
    @projects = Project.find :all,
                            :conditions => Project.visible_by(User.current),
                            :include => :parent
    if !params[:id]
      @project = @projects.first
    else
      @project = Project.find(params[:id])
    end
    find_files
    @members = @project.members
    @subprojects = @project.children.find(:all, :conditions => Project.visible_by(User.current))
    @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    @trackers = @project.rolled_up_trackers
    @users = User.all
    
    cond = @project.project_condition(Setting.display_subprojects_issues?)
   
    TimeEntry.visible_by(User.current) do
      @total_hours = TimeEntry.sum(:hours, 
                                   :include => :project,
                                   :conditions => cond).to_f
    end
    @key = User.current.rss_key
    @gantt = Redmine::Helpers::Gantt.new(params)
    retrieve_query
    if @query.valid?
      events = @project.stages(:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?)) and start_date is not null) AND #{Issue.table_name}.parent_id is null])", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to])

      @gantt.events = events
    end
    completed_percent
     find_gallery
    respond_to do |format|
      format.js  {
          render:update do |page|
            page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/show', :locals=>{:project=>@project})}');"
            page << "jQuery('#sidebar_new').html('#{escape_javascript(render:partial=>'projects/sidebar_new')}');"
          end
      }
    end

  end

  def settings
    @tags = Tags.all
    @root_projects = Project.find(:all,
                                  :conditions => ["status = #{Project::STATUS_ACTIVE} AND id <> ?", @project.id],
                                  :order => 'name')
    @time_units = TimeUnit.find(:all)
    @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
    @issue_category ||= IssueCategory.new
    @member ||= @project.members.new
    @trackers = Tracker.all
    @repository ||= @project.repository
    @wiki ||= @project.wiki
     @users = User.all
  end
  
  # Edit @project
  def edit
    if request.post?
      @tags = Tags.all
      @project.attributes = params[:project]
      @users = User.all
      select_tags =  params[:tags]
      @project.tag_list = ''
      select_tags.each do |tag|
        @project.tag_list << tag
      end
      if @project.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @project
      else
        settings
        render :action => 'settings'
      end
    end
  end
  
  def modules
    @project.enabled_module_names = params[:enabled_modules]
    redirect_to :action => 'settings', :id => @project, :tab => 'modules'
  end

  def archive
    @project.archive if request.post? && @project.active?
    redirect_to :controller => 'admin', :action => 'projects'
  end
  
  def unarchive
    @project.unarchive if request.post? && !@project.active?
    redirect_to :controller => 'admin', :action => 'projects'
  end
  
  # Delete @project
  def destroy
    @project_to_destroy = @project
    if request.post? and params[:confirm]
      @project_to_destroy.destroy
      redirect_to :controller => 'admin', :action => 'projects'
    end
    # hide project in layout
    @project = nil
  end
	
  # Add a new issue category to @project
  def add_issue_category
    @category = @project.issue_categories.build(params[:category])
    if request.post? and @category.save
  	  respond_to do |format|
        format.html do
          flash[:notice] = l(:notice_successful_create)
          redirect_to :action => 'settings', :tab => 'categories', :id => @project
        end
        format.js do
          # IE doesn't support the replace_html rjs method for select box options
          render(:update) {|page| page.replace "issue_category_id",
            content_tag('select', '<option></option>' + options_from_collection_for_select(@project.issue_categories, 'id', 'name', @category.id), :id => 'issue_category_id', :name => 'issue[category_id]')
          }
        end
      end
    end
  end
	
  # Add a new version to @project
  def add_version
  	@version = @project.versions.build(params[:version])
  	if request.post? and @version.save
  	  flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'settings', :tab => 'versions', :id => @project
  	end
  end

  def add_file
    @versions = @project.versions.sort
    if request.post?
      container = (params[:version_id].blank? ? @project : @project.versions.find_by_id(params[:version_id]))
      attachments = attach_files(container, params[:attachments])
      if !attachments.empty? && Setting.notified_events.include?('file_added')
        Mailer.deliver_attachments_added(attachments)
      end
      respond_to do |format|
        format.html {}
        format.js {
          render:update do |page|
            page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'add_file')}');"
          end
          }
      end
      return
    end
    
     
  end
  
  def list_files
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{FileAttachment.table_name}.filename",
                'created_on' => "#{FileAttachment.table_name}.created_on",
                'size' => "#{FileAttachment.table_name}.filesize",
                'downloads' => "#{FileAttachment.table_name}.downloads"
                
    @containers = [ Project.find(@project.id, :include => :attachments, :order => sort_clause)]
    @containers += @project.versions.find(:all, :include => :attachments, :order => sort_clause).sort.reverse
    render :layout => !request.xhr?
  end
  
  # Show changelog for @project
  def changelog
    @trackers = @project.trackers.find(:all, :conditions => ["is_in_chlog=?", true], :order => 'position')
    retrieve_selected_tracker_ids(@trackers)    
    @versions = @project.versions.sort
  end

  def roadmap
    @trackers = @project.trackers.find(:all, :conditions => ["is_in_roadmap=?", true])
    retrieve_selected_tracker_ids(@trackers)
    @versions = @project.versions.sort
    @versions = @versions.select {|v| !v.completed? } unless params[:completed]
  end
  
  def activity
    @days = Setting.activity_days_default.to_i
    
    if params[:from]
      begin; @date_to = params[:from].to_date + 1; rescue; end
    end

    @date_to ||= Date.today + 1
    @date_from = @date_to - @days
    @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
    @author = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))
    
    @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project, 
                                                             :with_subprojects => @with_subprojects,
                                                             :author => @author)
    @activity.scope_select {|t| !params["show_#{t}"].nil?}
    @activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?

    events = @activity.events(@date_from, @date_to)
    
    respond_to do |format|
      format.html { 
        @events_by_day = events.group_by(&:event_date)
        render :layout => false if request.xhr?
      }
      format.atom {
        title = l(:label_activity)
        if @author
          title = @author.name
        elsif @activity.scope.size == 1
          title = l("label_#{@activity.scope.first.singularize}_plural")
        end
        render_feed(events, :title => "#{@project || Setting.app_title}: #{title}")
      }
    end
    
  rescue ActiveRecord::RecordNotFound
    render_404
  end


  def tags_json
    tags_json = Project.tags_json
     render:text=>tags_json
  end

  
private
  # Find project of id params[:id]
  # if not found, redirect to project list
  # Used as a before_filter
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def retrieve_selected_tracker_ids(selectable_trackers)
    if ids = params[:tracker_ids]
      @selected_tracker_ids = (ids.is_a? Array) ? ids.collect { |id| id.to_i.to_s } : ids.split('/').collect { |id| id.to_i.to_s }
    else
      @selected_tracker_ids = selectable_trackers.collect {|t| t.id.to_s }
    end
  end

  def find_files
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{FileAttachment.table_name}.filename",
                'created_on' => "#{FileAttachment.table_name}.created_on",
                'size' => "#{FileAttachment.table_name}.filesize",
                'downloads' => "#{FileAttachment.table_name}.downloads"

    @containers = [ Project.find(@project.id, :include => :file_attachments, :order => sort_clause)]
    @containers += @project.versions.find(:all, :include => :file_attachments, :order => sort_clause).sort.reverse
  end

  def retrieve_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}

    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = @project
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        session[:query] = {:project_id => @query.project_id, :filters => @query.filters}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters])
        @query.project = @project
      end

    end
  end

  def completed_percent
    @completed_percent = 0
    @project.issues.issues.each do |issue|
      if issue.closed?
        @completed_percent += 1
      else
        @completed_percent += issue.done_ratio
      end
     end
     @completed_percent = @completed_percent/@project.issues.issues.count
  end

  def find_gallery
    @gallery = @project.gallery unless @project.nil?
    @photo = Photo.new
    @photo.gallery_id = @gallery.id unless @gallery.nil?
  end
  
  

end
