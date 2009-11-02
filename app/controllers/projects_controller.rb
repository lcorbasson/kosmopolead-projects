
# redMine - project management software
# Copyright (C) 2006-2007 Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

class ProjectsController < ApplicationController
  menu_item :projects,:only=>[:show]

  menu_item :activity, :only => :activity
  menu_item :roadmap, :only => :roadmap
  menu_item :files, :only => [:list_files, :add_file]
  menu_item :settings, :only => :settings

  before_filter :construct_menu,:except=>:add

  before_filter :find_root_projects
  before_filter :find_project, :except => [ :tags_json, :index, :list, :add, :activity,:update_left_menu ]
#  before_filter :define_community_context, :only=>[:index]

  before_filter :find_optional_project, :only => :activity
#  before_filter :authorize, :except => [:index,:add_file,:update, :tags_json,:index, :list, :add, :archive, :unarchive, :destroy, :activity,:update_left_menu, :edit_part_description, :edit_part_synthesis ]
#  before_filter :require_admin, :only => [ :add, :archive, :unarchive, :destroy ]
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

    # TODO cékoi ?
    if session[:query_projects]
      @query = session[:query_projects]     
    else
      retrieve_query
    end
    
    @relation = ProjectRelation.new

    if @project
      @gantt = Redmine::Helpers::Gantt.new(params.merge( :project => @project))
      @gantt.events = Issue.find(:all, :include=>[:type], :conditions => ["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
        and start_date is not null)
        AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

      @member ||= @project.members.new
      @users = User.all
      @file_attachment = FileAttachment.new(:container_id=>@project.id,:container_type=>"project")
      @roles = Role.find :all, :order => 'builtin, position'
      completed_percent
      find_gallery
      show_funding
    end

    respond_to do |format|
      format.html {}
      format.atom {
        render_feed(projects.sort_by(&:created_on).reverse.slice(0, Setting.feeds_limit.to_i),
          :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
      }
    end
  end

  # Add a new project
  def add
    require_community
    #Call to form
    if !params[:project]
      @project = Project.new :community => current_community
      @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
      @trackers = Tracker.all
      @time_units = TimeUnit.find(:all)
      @users = current_community.users
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
      #Save project
      @relation = ProjectRelation.new
      @project = current_community.projects.build
      @project.attributes = params[:project]
      @project.archived = false
      @project.enabled_module_names = params[:enabled_modules]
      @project.community = current_community     
      if @project.save
        @trackers = @project.rolled_up_trackers
        @users = User.all
        cond = @project.project_condition(Setting.display_subprojects_issues?)
        TimeEntry.visible_by(User.current) do
          @total_hours = TimeEntry.sum(:hours,
                                       :include => :project,
                                       :conditions => cond).to_f
        end
        @key = User.current.rss_key
        @gantt = Redmine::Helpers::Gantt.new(params.merge( :project => @project))
        @member ||= @project.members.new
        @users = User.all
        @file_attachment = FileAttachment.new(:container_type=>"project",:container_id=>@project.id)
        @roles = Role.find :all, :order => 'builtin, position'
        if @project.partner_id
          ProjectPartner.create(:project_id => @project.id,:partner_id => @project.partner_id)
        end
        retrieve_query
        if @query.valid?
          events = Issue.find(:all,:include=>[:type],:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
                            and start_date is not null)
                            AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

          @gantt.events = events
        end
        completed_percent
        find_gallery
        construct_menu
        session[:project] = @project
        flash[:notice] = l(:notice_successful_create)
        respond_to do |format|
          format.js do
            render:update do |page|
              page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/show', :locals=>{:project=>@project})}');"
              page << "jQuery('#projects_menu').html('#{escape_javascript(render:partial=>'projects/projects_menu')}');"
              page << display_message_error(l(:notice_successful_create), "fieldNotice")
              page << "Element.scrollTo('errorExplanation');"
            end
          end
        end
      else
        respond_to do |format|
          format.js do
            render :update do |page|#
               page << display_message_error(@project, "fieldError")
               page << "Element.scrollTo('errorExplanation');"
            end
          end
        end
      end
    end
  end

  # Show @project
  def show
    if session[:query_projects]
      @query = session[:query_projects]  
    else
      retrieve_query
    end
    if params[:jump]
      # try to redirect to the requested menu item
      redirect_to_project_menu_item(@project, params[:jump]) && return
    end

    if !params[:id]   
        @project = @projects.first 
    else      
        find_project     
    end
    @allowed_statuses = IssueStatus.all
    @relation = ProjectRelation.new
    @members = @project.members
    @subprojects = @project.children.find(:all, :conditions => Project.visible_by(User.current))
    @news = @project.news.find(:all, :limit => 5, :include => [ :author, :project ], :order => "#{News.table_name}.created_on DESC")
    @trackers = @project.rolled_up_trackers
    @users = @project.community.users

    cond = @project.project_condition(Setting.display_subprojects_issues?)

    TimeEntry.visible_by(User.current) do
      @total_hours = TimeEntry.sum(:hours,
                                   :include => :project,
                                   :conditions => cond).to_f
    end
    @key = User.current.rss_key
    @gantt = Redmine::Helpers::Gantt.new(params.merge( :project => @project))
    @member ||= @project.members.new
    @users = User.all
    @file_attachment = FileAttachment.new
    @file_attachment.container_id = @project.id
    @file_attachment.container_type = "project"
    @roles = Role.find :all, :order => 'builtin, position'
   
    if @query.valid?
      events = Issue.find(:all,:include=>[:type],:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
                                                                and start_date is not null)
                                                                AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

      @gantt.events = events
    end
    completed_percent
    find_gallery
    show_funding
    session[:project] = @project
    respond_to do |format|
      format.html { render :layout=>false}
      format.js {
          render:update do |page|
            page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/show', :locals=>{:project=>@project})}');"
            page << "jQuery('#sidebar_new').html('#{escape_javascript(render:partial=>'projects/sidebar_new')}');"
          end
      }
    end
  end

  def settings
    @tags = Tags.all 
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
      @project.attributes = params[:project]
      @users = User.all

      if @project.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'settings', :id => @project
      else
        settings
        render :action => 'settings'
      end
    end
  end


  def update
    @project = Project.find_by_identifier(params[:id])    
    @project.update_attributes(params[:project])
    respond_to do |format|
      format.js {
        render(:update) {|page|
          case params[:part]
            when "description"   
              page << "jQuery('.project_description').html('#{escape_javascript(render:partial=>'projects/box/description',:locals=>{:project=>@project})}');"
            when "tags"
              @project.tag_list = ''
              if select_tags = params[:tags]
                select_tags.each do |tag|
                  @project.tag_list << tag
                end
              end
              page << "jQuery('.project_tags').html('#{escape_javascript(render:partial=>'projects/box/tags')}');"
            when "summary"              
              @users = User.all
              page << refresh_title(@project);
              page << "jQuery('#profile_project').html('#{escape_javascript(profile_project_box("PROJET #{@project.name.upcase}","#{render:partial=>'projects/box/profile',:locals=>{:project=>@project}}"))}');"
              if @project.author_id
                unless @project.members.collect(&:user).include?(@project.author)
                  @project.members << Member.new(:user_id => @project.author_id, :role_id => Role.default.id)
                  page.replace_html "projects_members", :partial => 'projects/show/members', :locals=>{:project=>@project}
                end
              end
              if @project.partner_id
                unless @project.partners.include?(@project.partner)
                  @project.project_partners << ProjectPartner.new(:partner_id => @project.partner_id)
                   page.replace_html "projects_partners", :partial => 'projects/show/partners', :locals=>{:project=>@project}
                end
              end
              page.replace_html "project_author", :partial =>"projects/author",:locals=>{:project=>@project}
            when "synthesis"
              page.replace_html "tab-content-synthesis", :partial => 'projects/show/synthesis',:locals=>{:project=>@project}
            when "custom_fields"                
              page.replace_html "custom_fields", :partial => 'projects/show/custom_fields',:locals=>{:project=>@project}
          end          
          if @project.save
            page << display_message_error(l(:notice_successful_update), "fieldNotice")
          else
            page << display_message_error(@project, "fieldError")
          end
          page << "Element.scrollTo('errorExplanation');"
        }
      }
    end
  end

  def update_left_menu
    @status = params[:status] ? params[:status].to_i : 1
    c = ARCondition.new(@status == 0 ? "status <> 0" : ["status = ?", @status])

    @projects = Project.find :all,
                        :conditions => c.conditions

    respond_to do |format|
      format.js {
        render :update do |page|
           page << "jQuery('#projects_menu').html('#{escape_javascript(render:partial=>'projects/projects_menu')}');"
        end
      }
    end
  end


  def modules
    @project.enabled_module_names = params[:enabled_modules]
    redirect_to :action => 'settings', :id => @project, :tab => 'modules'
  end

  def archive
    @project.archive if request.post?
    flash[:notice] = l(:notice_successful_archive)
    redirect_to :controller => 'admin', :action => 'projects'
  end

  def unarchive
    @project.unarchive if request.post?
    flash[:notice] = l(:notice_successful_unarchive)
    redirect_to :controller => 'admin', :action => 'projects'
  end

  # Delete @project
  def destroy
    @project_to_destroy = @project
    if request.post? and params[:confirm]
      if @project_to_destroy.destroy
        session[:project] = nil
        flash[:notice] = l(:notice_successful_delete)
        redirect_to :controller => 'admin', :action => 'projects'
      else
        flash[:error] = l(:error_can_t_do)
        redirect_to :controller => 'admin', :action => 'projects'
      end
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
      @file = FileAttachment.new
      @file.container_id = @project.id
      @file.container_type = "project"
      render :layout=>false
  end

  def list_files
    sort_init 'filename', 'asc'
    sort_update 'filename' => "#{FileAttachment.table_name}.filename",
                'acronym' => "#{FileAttachment.table_name}.acronym",
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
  
  def edit_part_description
    @project = Project.find(params[:project_id])   

    respond_to do |format|
      format.js {
        render :update do |page|
           page << "jQuery('#description').html('#{escape_javascript(render:partial=>'projects/edit_part_description')}');"
        end
      }
    end
  end

  def edit_part_synthesis
    @project = Project.find(params[:project_id])
    render :layout=>false
  end

  def edit_part_profile
    @project = Project.find(params[:project_id])
    render :layout=>false
  end

  def refresh_menu
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
      session[:query_projects] =  @query
      if @query.valid?
        conditions = @query.statement_projects

        @projects = Project.find :all,                             
                             :conditions => "#{conditions}",
                             :order => 'acronym'

        @project = @projects.first unless @projects.nil?
        @relation= ProjectRelation.new
     unless @project.nil?
          @gantt = Redmine::Helpers::Gantt.new(params.merge( :project => @project))
          retrieve_query
          if @query.valid?
             events = Issue.find(:all,:include=>[:type],:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
                                                                      and start_date is not null)
                                                                      AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

            @gantt.events = events
          end
          @member ||= @project.members.new
          @users = User.all
          @file_attachment = FileAttachment.new(:container_id=>@project.id,:container_type=>"project")
          @roles = Role.find :all, :order => 'builtin, position'
          completed_percent
          find_gallery
          show_funding
      end
        respond_to do |format|
          format.js {
            render(:update) {|page|
              page<<"jQuery('#sidebar_projects').html('#{escape_javascript(render:partial=>'projects/projects_menu')}');"
              page<<"jQuery('#sidebar_new').html('#{escape_javascript(render:partial=>'projects/sidebar_new')}');"
              page<<"jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/show', :locals=>{:project=>@project,:show_filters=>true})}');"
              }
          }
        end
      else
        # Send html if the query is not valid
        render(:template => 'queries/index.rhtml', :layout => !request.xhr?)
      end
  end

  def list_members_community
   @members = Community.current.users.like("#{params[:q]}%")
    render :layout=>false
  end

  def list_partners
      @user = User.find(params[:user_id])
      @partners = @user.partnerships.collect { |ps| ps.partner}
      respond_to do |format|
          format.js {
            render(:update) {|page|
              page.replace_html "list_partners", content_tag('label',l(:label_partner))+content_tag('select', options_from_collection_for_select(@partners, 'id', 'name'), :id => 'project_partner_id', :name => 'project[partner_id]')
            }
          }
     end
  end

  def list_partners_community
      @community = current_community
      @partners = @community.partners.like("#{params[:q]}%")
      render :layout=>false
  end

  def list_partnerships
    @partner = Partner.find(params[:partner_id])
    respond_to do |format|
          format.js {
            render(:update) {|page|
              page.replace_html "member_users", content_tag('select', options_from_collection_for_select(@partner.members, 'id', 'name'), :id => 'member_user_id', :name => 'member[user_id]')

              }
          }
     end
  end

  
private
  # Find project of id params[:id]
  # if not found, redirect to project list
  # Used as a before_filter
  def find_project

      @project = Project.find_by_identifier(params[:id])

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project
    return true unless params[:id]
    if params[:id].is_a?(Integer)
      @project = Project.find(params[:id])
    else
      @project = Project.find_by_identifier(params[:id])
    end
   
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



  def retrieve_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)    
      session[:query] = {:id => @query.id}

    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")       
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        session[:query] = {:filters => @query.filters}
      else
        @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
        @query ||= Query.new(:name => "_", :project => @project, :filters => session[:query][:filters])
       
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
     if @completed_percent > 0
       @completed_percent = @completed_percent/@project.issues.issues.count
     end
  end

  def find_gallery
    unless @project.nil?
      unless @gallery = @project.gallery
        @gallery = Gallery.create(:owned_id=>@project.id, :owned_type=>"project")
      end
    end
    @photo = Photo.new
    @photo.gallery_id = @gallery.id unless @gallery.nil?
  end


  def find_root_projects
    @root_projects = current_community ? current_community.projects.all(:order => 'acronym') : Project.all(:order => 'acronym')
  end

  def show_funding 
    @funding_lines = @project.funding_lines
  end

end




