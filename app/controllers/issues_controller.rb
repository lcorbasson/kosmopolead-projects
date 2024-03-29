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

class IssuesController < ApplicationController

  menu_item :projects

  before_filter :construct_menu

  menu_item :new_issue, :only => :news

  
  before_filter :find_issue, :only => [:show, :edit, :reply]
  before_filter :find_issues, :only => [:bulk_edit, :move, :destroy]
  before_filter :find_project, :only => [:update,:calendar,:gantt,:index,:create,:new, :update_form, :preview,:type_event]
  before_filter :find_root_projects,:only=>[:create]
  before_filter :only => [:update,:gantt, :index, :calendar,:new,:show,:create]
#  before_filter :authorize, :except => [:update,:type_event,:type_stage,:create,:index, :changes, :gantt, :calendar, :preview, :update_form, :context_menu]

#  before_filter :find_optional_project, :only => [ :changes, :gantt, :calendar]
  accept_key_auth :index, :show, :changes

  helper :journals
  helper :projects
  include ProjectsHelper   
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :file_attachments
  include FileAttachmentsHelper
  helper :queries
  helper :sort
  include SortHelper
  include IssuesHelper
  helper :timelog
  include Redmine::Export::PDF

  def index
    if !params[:project_id]
      @project = @projects.first
    end
    retrieve_query
    sort_init 'id', 'desc'
    sort_update({'id' => "#{Issue.table_name}.id"}.merge(@query.columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))

  
    if @query.valid?
      limit = per_page_option
      respond_to do |format|
        format.html { }
        format.atom { }
        format.csv  { limit = Setting.issues_export_limit.to_i }
        format.pdf  { limit = Setting.issues_export_limit.to_i }
      end
      @issue_count = Issue.count(:include => [:status, :project], :conditions => @query.statement)
      @issue_pages = Paginator.new self, @issue_count, limit, params['page']
      @issues = Issue.find :all, :order => sort_clause,
                           :include => [ :parent, :status, :tracker, :project, :priority],
                           :conditions => "#{'('+@query.statement+')'+' and ' if !@query.statement.blank?} issues.parent_id is NULL" ,
                           :limit  =>  limit,
                           :offset =>  @issue_pages.current.offset
      respond_to do |format|
        format.html { }
        format.atom { render_feed(@issues, :title => "#{@project || Setting.app_title}: #{l(:label_issue_plural)}") }
        format.csv  { send_data(issues_to_csv(@issues, @project).read, :type => 'text/csv; header=present', :filename => 'export.csv') }
        format.pdf  { send_data(issues_to_pdf(@issues, @project), :type => 'application/pdf', :filename => 'export.pdf') }
        format.js  {
          render:update do |page|
            if !params[:set_filter]
             page.replace_html "content_wrapper", :partial => 'issues/index', :locals=>{:project=>@project}
             page.replace_html "project_author", :partial => 'projects/author', :locals=>{:project=>@project}
            else
              page.replace_html "list_issues", :partial => 'issues/list', :locals => {:issues => @issues, :query => @query}
            end
          end
        }
      end
    else
      # Send html if the query is not valid
      render(:template => 'issues/index.rhtml', :layout => !request.xhr?)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def changes
    retrieve_query
    sort_init 'id', 'desc'
    sort_update({'id' => "#{Issue.table_name}.id"}.merge(@query.columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))
    
    if @query.valid?
      @journals = Journal.find :all, :include => [ :details, :user, {:issue => [:project, :author, :tracker, :status]} ],
                                     :conditions => @query.statement,
                                     :limit => 25,
                                     :order => "#{Journal.table_name}.created_on DESC"
    end
    @title = (@project ? @project.name : Setting.app_title) + ": " + (@query.new_record? ? l(:label_changes_details) : @query.name)
    render :layout => false, :content_type => 'application/atom+xml'
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def show
    @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?
    #@allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @allowed_statuses = IssueStatus.all
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @priorities = Enumeration::get_values('IPRI')
    @time_entry = TimeEntry.new
    @project = @issue.project
    @file_attachment = FileAttachment.new
    @file_attachment.container_type="issue"
    @file_attachment.container_id = @issue.id
    respond_to do |format|
      format.html { render :template => 'issues/show.rhtml' }
      format.atom { render :action => 'changes', :layout => false, :content_type => 'application/atom+xml' }
      format.pdf  { send_data(issue_to_pdf(@issue), :type => 'application/pdf', :filename => "#{@project.identifier}-#{@issue.id}.pdf") }
      format.js {
        render:update do |page|
          page << "jQuery('#content').html('#{escape_javascript(render:partial=>'show')}');"
        end
        }
    end
  end

  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    @issues = Issue.all
    @issue = Issue.new
    @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @issue.copy_from(params[:copy_from]) if params[:copy_from]
    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    @issue.issue_types_id ||= IssueType.find((params[:issue] && params[:issue][:issue_type_id]) || params[:issue_type_id] || :first)
    @issue_types = IssueType.find(:all)
    @users = User.all
    if @issue.tracker.nil?
      respond_to do |format|
        format.js{
          render :update do |page|#
            page << display_message_error("No tracker is associated to this project. Please check the Project settings.", "fieldError")
          end
        }
      end
#      render :nothing => true, :layout => true
      return
    end
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current
    
    default_status = IssueStatus.default
    unless default_status
      respond_to do |format|
        format.js{
          render :update do |page|#
            page << display_message_error("No default issue status is defined. Please check your configuration (Go to Administration -> Issue statuses).", "fieldError")
          end
        }
      render :nothing => true, :layout => true
      return
    end
    end
    @issue.status = default_status
    @allowed_statuses = ([default_status] + default_status.find_new_statuses_allowed_to(User.current.role_for_project(@project), @issue.tracker)).uniq
    
    if request.get? || request.xhr?
      @issue.start_date ||= Date.today
      if params[:issue_type]        
          @issue_type = IssueType.find(:first,:conditions=>["name = ?",params[:issue_type]])
          @issue.issue_types_id = @issue_type.id
      end
    else
      requested_status = IssueStatus.find_by_id(params[:issue][:status_id])
      # Check that the user is allowed to apply the requested status
      @issue.status = (@allowed_statuses.include? requested_status) ? requested_status : default_status
     if !params[:parent_id].nil?
       @issue.parent_id = params[:parent_id]
     end      		
    end	
    @priorities = Enumeration::get_values('IPRI')   
    respond_to do |format|
      format.html {}
      format.js {
        render:update do |page|
          page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'new')}');"
        end
        }
    end   
  end


  def create
    @issue = Issue.new(params[:issue])
    has_error = false
    find_info_issue
    # Des trackers ont-ils été définis ?
    if @issue.tracker.nil?
      respond_to do |format|
          format.js {
            render:update do |page|
                page << display_message_error(l(:error_no_tracker), "fieldWarning")
                page << "Element.scrollTo('content_wrapper');"
            end
          }
      end
    end
    # Save custom fields
     @issue.save_custom_field_values
    if params[:issue].is_a?(Hash)
      @issue.attributes = params[:issue]
      @issue.watcher_user_ids = params[:issue]['watcher_user_ids'] if User.current.allowed_to?(:add_issue_watchers, @project)
    end
    @issue.author = User.current
    @priorities = Enumeration::get_values('IPRI')    
    @project.attributes = params[:project]
          find_info_issue        
          if @issue.save
              @file_attachment = FileAttachment.new
              @file_attachment.container_type="issue"
              @file_attachment.container_id = @issue.id
              find_info_project  if @issue.is_stage?
               # La tache est assignee
           if params[:assigned_to_id]
             create_assignments(params[:assigned_to_id])
           else
             # La tache n est pas assignee
            Assignment.delete(@issue)
          end
            find_info_project  if @issue.is_stage?
            respond_to do |format|
                format.js {
                  render:update do |page|
                     if @issue.is_stage?                     
                       page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'projects/show', :locals=>{:project=>@project})}');"
                     else                     
                       page.replace_html "content_wrapper", :partial => 'show'
                     end
                     page << display_message_error(l(:notice_successful_create), "fieldNotice")
                      page << "Element.scrollTo('errorExplanation');"
                   end
                }
             end
          else
            respond_to do |format|
                format.js {
                  render:update do |page|
                     page << display_message_error(@issue, "fieldError")
                     page << "Element.scrollTo('errorExplanation');"
                  end
                }
            end
          end
     
  end
  
  # Attributes that can be updated on workflow transition (without :edit permission)
  # TODO: make it configurable (at least per role)
  UPDATABLE_ATTRS_ON_TRANSITION = %w(status_id assigned_to_id fixed_version_id done_ratio) unless const_defined?(:UPDATABLE_ATTRS_ON_TRANSITION)

  def update
    @issue = Issue.find(params[:id])
    if @issue.update_attributes(params[:issue])
      # La tache est assignee
       if params[:assigned_to_id]
         create_assignments(params[:assigned_to_id])
       else
         # La tache n est pas assignee
        Assignment.delete(@issue)
      end
      @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
      @journals.each_with_index {|j,i| j.indice = i+1}
      @journals.reverse! if User.current.wants_comments_in_reverse_order?
      #@allowed_statuses = @issue.new_statuses_allowed_to(User.current)
      @allowed_statuses = IssueStatus.all
      @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
      @priorities = Enumeration::get_values('IPRI')
      @time_entry = TimeEntry.new
      @project = @issue.project
      @file_attachment = FileAttachment.new
      @file_attachment.container_type="issue"
      @file_attachment.container_id = @issue.id      
        respond_to do |format|
          format.html {}
          format.js {
            render(:update) {|page| 
              page.replace_html "content_wrapper", :partial => 'issues/show'
              page << display_message_error(l(:notice_successful_update), "fieldNotice")
              }
          }
        end
    else
       respond_to do |format|
          format.html {}
          format.js {
            render(:update) {|page|
              page.replace_html "content_wrapper", :partial => 'issues/show'
              page << display_message_error(l(:error_can_t_do), "fieldError")
              }
          }
        end

    end


  end


  def edit
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @priorities = Enumeration::get_values('IPRI')
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @time_entry = TimeEntry.new    
    @notes = params[:notes]
    @project = @issue.project
    journal = @issue.init_journal(User.current, @notes)
    # User can change issue attributes only if he has :edit permission or if a workflow transition is allowed
    if (@edit_allowed || !@allowed_statuses.empty?) && params[:issue]
      attrs = params[:issue].dup
      attrs.delete_if {|k,v| !UPDATABLE_ATTRS_ON_TRANSITION.include?(k) } unless @edit_allowed
      attrs.delete(:status_id) unless @allowed_statuses.detect {|s| s.id.to_s == attrs[:status_id].to_s}
      @issue.attributes = attrs
      if @issue.is_issue?
        # La tache est assignee
         if params[:assigned_to_id]
          create_assignments(params[:assigned_to_id])
         else
           # La tache n est pas assignee
          Assignment.delete(@issue)
        end
      end
    end

    if request.post?
      @time_entry = TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => Date.today)
      @time_entry.attributes = params[:time_entry]
     
      call_hook(:controller_issues_edit_before_save, { :params => params, :issue => @issue, :time_entry => @time_entry, :journal => journal})

      if (@time_entry.hours.nil? || @time_entry.valid?) && @issue.save
        # Log spend time
        if User.current.allowed_to?(:log_time, @project)
          @time_entry.save
        end
        if !journal.new_record?
          # Only send notification if something was actually changed
          flash[:notice] = l(:notice_successful_update)
          Mailer.deliver_issue_edit(journal) if Setting.notified_events.include?('issue_updated')
        end
        redirect_to(params[:back_to] || {:action => 'show', :id => @issue})
      end
    end
  rescue ActiveRecord::StaleObjectError
    # Optimistic locking exception
    flash.now[:error] = l(:notice_locking_conflict)
  end

  def reply
    journal = Journal.find(params[:journal_id]) if params[:journal_id]
    if journal
      user = journal.user
      text = journal.notes
    else
      user = @issue.author
      text = @issue.description
    end
    content = "#{ll(Setting.default_language, :text_user_wrote, user)}\\n> "
    content << text.to_s.strip.gsub(%r{<pre>((.|\s)*?)</pre>}m, '[...]').gsub('"', '\"').gsub(/(\r?\n|\r\n?)/, "\\n> ") + "\\n\\n"
    render(:update) { |page|
      page.<< "$('notes').value = \"#{content}\";"
      page.show 'update'
      page << "Form.Element.focus('notes');"
      page << "Element.scrollTo('update');"
      page << "$('notes').scrollTop = $('notes').scrollHeight - $('notes').clientHeight;"
    }
  end
  
  # Bulk edit a set of issues
  def bulk_edit

    if request.post?    
      status = params[:status_id].blank? ? nil : IssueStatus.find_by_id(params[:status_id])
      priority = params[:priority_id].blank? ? nil : Enumeration.find_by_id(params[:priority_id])
      assigned_to = (params[:assigned_to_id].blank? || params[:assigned_to_id] == 'none') ? nil : User.find_by_id(params[:assigned_to_id])
      category = (params[:category_id].blank? || params[:category_id] == 'none') ? nil : @project.issue_categories.find_by_id(params[:category_id])
      fixed_version = (params[:fixed_version_id].blank? || params[:fixed_version_id] == 'none') ? nil : @project.versions.find_by_id(params[:fixed_version_id])
      
      unsaved_issue_ids = []      
      @issues.each do |issue|
        journal = issue.init_journal(User.current, params[:notes])
        issue.priority = priority if priority
        issue.assigned_to = assigned_to if assigned_to || params[:assigned_to_id] == 'none'
        issue.category = category if category || params[:category_id] == 'none'
        issue.fixed_version = fixed_version if fixed_version || params[:fixed_version_id] == 'none'
        issue.start_date = params[:start_date] unless params[:start_date].blank?
        issue.due_date = params[:due_date] unless params[:due_date].blank?
        issue.done_ratio = params[:done_ratio] unless params[:done_ratio].blank?
        call_hook(:controller_issues_bulk_edit_before_save, { :params => params, :issue => issue })
        # Don't save any change to the issue if the user is not authorized to apply the requested status
        if (status.nil? || (issue.status.new_status_allowed_to?(status, current_role, issue.tracker) && issue.status = status)) && issue.save
          # Send notification for each issue (if changed)
          Mailer.deliver_issue_edit(journal) if journal.details.any? && Setting.notified_events.include?('issue_updated')
        else
          # Keep unsaved issue ids to display them in flash error
          unsaved_issue_ids << issue.id
        end
      end
      if unsaved_issue_ids.empty?
        flash[:notice] = l(:notice_successful_update) unless @issues.empty?
      else
        flash[:error] = l(:notice_failed_to_save_issues, unsaved_issue_ids.size, @issues.size, '#' + unsaved_issue_ids.join(', #'))
      end
      redirect_to({:controller => 'issues', :action => 'index', :project_id => @project})
      return
    end
    # Find potential statuses the user could be allowed to switch issues to
    @available_statuses = Workflow.find(:all, :include => :new_status,
                                              :conditions => {:role_id => current_role.id}).collect(&:new_status).compact.uniq.sort
  end

  def move
    @issues = Issue.find_all_by_id(params[:id] || params[:ids])

    @allowed_projects = []
    # find projects to which the user is allowed to move the issue
    if User.current.admin?
      # admin is allowed to move issues to any active (visible) project
      @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current), :order => 'name')
    else
      User.current.memberships.each {|m| @allowed_projects << m.project if m.role.allowed_to?(:move_issues)}
    end
    @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
    @target_project ||= @project    
    @trackers = @target_project.trackers
    if request.post?
      new_tracker = params[:new_tracker_id].blank? ? nil : @target_project.trackers.find_by_id(params[:new_tracker_id])
      unsaved_issue_ids = []
      @issues.each do |issue|
        issue.init_journal(User.current)
        unsaved_issue_ids << issue.id unless issue.move_to(@target_project, new_tracker)
      end
      if unsaved_issue_ids.empty?
        flash[:notice] = l(:notice_successful_update) unless @issues.empty?
      else
        flash[:error] = l(:notice_failed_to_save_issues, unsaved_issue_ids.size, @issues.size, '#' + unsaved_issue_ids.join(', #'))
      end
      redirect_to :controller => 'issues', :action => 'index', :project_id => @project
      return
    end
    render :layout => false if request.xhr?
  end
  
  def destroy
   @hours = TimeEntry.sum(:hours, :conditions => ['issue_id IN (?)', @issues]).to_f
    if @hours > 0
      case params[:todo]
      when 'destroy'
        # nothing to do
      when 'nullify'
        TimeEntry.update_all('issue_id = NULL', ['issue_id IN (?)', @issues])
      when 'reassign'
        reassign_to = @project.issues.find_by_id(params[:reassign_to_id])
        if reassign_to.nil?
          flash.now[:error] = l(:error_issue_not_found_in_project)
          return
        else
          TimeEntry.update_all("issue_id = #{reassign_to.id}", ['issue_id IN (?)', @issues])
        end
      else
        # display the destroy form
        return
      end
    end
    if @issues.each(&:destroy)
      flash[:notice] = l(:notice_successful_delete) unless @issues.empty?
    else
      flash[:error] = l(:error_can_t_do) unless @issues.empty?
    end
    redirect_to :action => 'index', :project_id => @project
  end
  
  def gantt
    @gantt = Redmine::Helpers::Gantt.new(params.merge(:project => @project))
    retrieve_query
   if @query.valid?
      events = []
      if params[:from] == "project"
        events = Issue.find(:all,:include=>[:type],:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
                                                                      and start_date is not null)
                                                                      AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

      
      else
        # Issues that have start and due dates
        events += Issue.find(:all,
                             :order => "#{Issue.table_name}.start_date, #{Issue.table_name}.due_date",
                             :include => [:tracker, :status,  :priority, :project],
                             :conditions => ["(#{@query.statement}) AND (((#{Issue.table_name}.start_date>=? and #{Issue.table_name}.start_date<=?) or (#{Issue.table_name}.due_date>=? and #{Issue.table_name}.due_date<=?) or (#{Issue.table_name}.start_date<? and #{Issue.table_name}.due_date>?)) and #{Issue.table_name}.start_date is not null and #{Issue.table_name}.due_date is not null) AND #{Issue.table_name}.parent_id is null", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to]
                             )
        # Issues that don't have a due date but that are assigned to a version with a date
        events += Issue.find(:all,
                             :order => "#{Issue.table_name}.start_date",
                             :include => [:tracker, :status,  :priority, :project],
                             :conditions => ["(#{@query.statement}) AND (((#{Issue.table_name}.start_date>=? and #{Issue.table_name}.start_date<=?)) and #{Issue.table_name}.start_date is not null and #{Issue.table_name}.due_date is null) AND #{Issue.table_name}.parent_id is null", @gantt.date_from, @gantt.date_to]
                             )
        # Versions
        events += Version.find(:all, :include => :project,
                                     :conditions => ["(#{@query.project_statement}) AND effective_date BETWEEN ? AND ? ", @gantt.date_from, @gantt.date_to])
      end
      @gantt.events = events
    end
    
    basename = (@project ? "#{@project.identifier}-" : '') + 'gantt'
    
    respond_to do |format|
      format.html { render :template => "issues/gantt.rhtml", :layout => !request.xhr? }
      format.png  { send_data(@gantt.to_image, :disposition => 'inline', :type => 'image/png', :filename => "#{basename}.png") } if @gantt.respond_to?('to_image')
      format.pdf  { send_data(gantt_to_pdf(@gantt, @project), :type => 'application/pdf', :filename => "#{basename}.pdf") }
      format.js  {
          render:update do |page|
            if params[:from] == "project"
              page << "jQuery('#tab-content-gantt').html('#{escape_javascript(render:partial=>'projects/show/gantt')}');"
            else
              page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'issues/gantt', :locals=>{:project=>@project})}');"
            end
          end
        }
    end
  end
  
  def calendar
    if params[:year] and params[:year].to_i > 1900
      @year = params[:year].to_i
      if params[:month] and params[:month].to_i > 0 and params[:month].to_i < 13
        @month = params[:month].to_i
      end    
    end
    @year ||= Date.today.year
    @month ||= Date.today.month
    
    @calendar = Redmine::Helpers::Calendar.new(Date.civil(@year, @month, 1), current_language, :month)
    retrieve_query
    if @query.valid?
      events = []
      events += Issue.find(:all, 
                           :include => [:tracker, :status, :assigned_to, :priority, :project], 
                           :conditions => ["#{'('+@query.project_statement+')'+' and ' if @query.statement} ((start_date BETWEEN ? AND ?) OR (due_date BETWEEN ? AND ?))", @calendar.startdt, @calendar.enddt, @calendar.startdt, @calendar.enddt]
                           )
      events += Version.find(:all, :include => :project,
                                   :conditions => ["#{'('+@query.project_statement+')'+' and ' if @query.statement}    effective_date BETWEEN ? AND ?", @calendar.startdt, @calendar.enddt])
                                     
      @calendar.events = events
    end
    respond_to do |format|
       format.js  {
          render:update do |page|
            page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'issues/calendar', :locals=>{:project=>@project})}');"

          end
        }
    end
   
  end
  
  def context_menu
    @issues = Issue.find_all_by_id(params[:ids], :include => :project)
    if (@issues.size == 1)
      @issue = @issues.first
      @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    end
    projects = @issues.collect(&:project).compact.uniq
    @project = projects.first if projects.size == 1

    @can = {:edit => (@project && User.current.allowed_to?(:edit_issues, @project)),
            :log_time => (@project && User.current.allowed_to?(:log_time, @project)),
            :update => (@project && (User.current.allowed_to?(:edit_issues, @project) || (User.current.allowed_to?(:change_status, @project) && @allowed_statuses && !@allowed_statuses.empty?))),
            :move => (@project && User.current.allowed_to?(:move_issues, @project)),
            :copy => (@issue && @project.trackers.include?(@issue.tracker) && User.current.allowed_to?(:add_issues, @project)),
            :delete => (@project && User.current.allowed_to?(:delete_issues, @project))
            }
    if @project
      @assignables = @project.assignable_users
      @assignables << @issue.assigned_to if @issue && @issue.assigned_to && !@assignables.include?(@issue.assigned_to)
    end
    
    @priorities = Enumeration.get_values('IPRI').reverse
    @statuses = IssueStatus.find(:all, :order => 'position')
    @back = request.env['HTTP_REFERER']
    
    render :layout => false
  end

  def update_form
    @issue = Issue.new(params[:issue])
    
    render :action => :new, :layout => false
  end
  
  def preview
    @issue = @project.issues.find_by_id(params[:id]) unless params[:id].blank?
    @attachements = @issue.file_attachments if @issue
    @text = params[:notes] || (params[:issue] ? params[:issue][:description] : nil)
    render :partial => 'common/preview'
  end


  def type_event
    @issues_stage = @project.issues.stages
    @issues_sub = @project.issues.issues
    
    # Instanciation de variable
  type = params[:type]
   respond_to do |format|
        format.js {
          render :update do |page|
            if type ==  'issue'
                    page << "jQuery('#type_relation').html('#{escape_javascript(render :partial=>'type_issue')}');"
                  end
                 if type == 'stage'
                    page << "jQuery('#type_relation').html('#{escape_javascript(render :partial=>'type_stage')}');"
                 end
                 
                  if type == 'none'
                    page << "jQuery('#type_relation').html('#{escape_javascript(render :partial=>'type_none')}');"
                  end
          end
        }
      end
  end
  
private
  def find_issue

    @issue = Issue.find(params[:id], :include => [:project, :tracker, :status, :author, :priority, :category])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # Filter for bulk operations
  def find_issues
    @issues = Issue.find_all_by_id(params[:id] || params[:ids])
    raise ActiveRecord::RecordNotFound if @issues.empty?
    projects = @issues.collect(&:project).compact.uniq
    if projects.size == 1
      @project = projects.first
    else
      # TODO: let users bulk edit/move/destroy issues from different projects
      render_error 'Can not bulk edit/move/destroy issues from different projects' and return false
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
  end
  
  
  # Retrieve query from session or build a new query
  def retrieve_query
    if !params[:query_id].blank?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = Query.find(params[:query_id], :conditions => cond)
      @query.project = @project
      @query.query_type = "issue"
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
      
    else
      if params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = @project
         @query.query_type = "issue"
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
        @query.query_type = "issue"
      end
     
    end
  end



  def find_root_projects
     @root_projects = Project.find(:all,
                                    
                                    :order => 'name')
  end

  def create_assignments(assignments)
    new_assignments = assignments
    Assignment.delete(@issue)
    #Création des assignations à la tâche
    new_assignments.each do |assigned_to|
      unless Assignment.exist?(@issue.id,assigned_to)
        @issue.assignments << Assignment.new(:issue_id=>@issue.id, :user_id=>assigned_to)
      end
    end
  end

  def find_info_project
    @relation= ProjectRelation.new
    @member ||= @project.members.new
    @users = User.all
    @file_attachment = FileAttachment.new(:container_id=>@project.id,:container_type=>"project")
    @roles = Role.find :all, :order => 'builtin, position'
    @gantt = Redmine::Helpers::Gantt.new(params.merge( :project => @project))
    retrieve_query
    if @query.valid?
      events = Issue.find(:all,:include=>[:type],:conditions=>["(((start_date>=? and start_date<=?) or (due_date>=? and due_date<=?) or (start_date<? and due_date>?))
                                                                and start_date is not null)
                                                                AND #{Issue.table_name}.parent_id is null and project_id = ? and #{IssueType.table_name}.name='STAGE'", @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to, @gantt.date_from, @gantt.date_to,@project.id])

      @gantt.events = events
    end
    @photo = Photo.new
    @photo.gallery_id = @project.gallery.id
  end

  def find_info_issue
     @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @issue.copy_from(params[:copy_from]) if params[:copy_from]
    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    @issue.issue_types_id ||= IssueType.find((params[:issue] && params[:issue][:issue_type_id]) || params[:issue_type_id] || :first)
    @issue_types = IssueType.find(:all)
    @users = User.all
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
  end

end
