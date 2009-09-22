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

class QueriesController < ApplicationController
  menu_item :queries
  before_filter :find_query, :except => [:projects,:new,:index]
  before_filter :find_queries, :only => [:projects,:index]
  before_filter :find_optional_project, :only => [:edit,:new,:index]

  helper :sort
  include SortHelper

  def index
   retrieve_query
   render :layout => !request.xhr?
  end
  
  def new
    @query = Query.new(params[:query])
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.user = User.current
    @query.is_public = false unless (@query.project && current_role.allowed_to?(:manage_public_queries)) || User.current.admin?
    @query.column_names = nil if params[:default_columns]
    @query.community = current_community unless @query.project
    
    params[:fields].each do |field|
      @query.add_filter(field, params[:operators][field], params[:values][field])
    end if params[:fields]
    @query.query_type = params[:query_type]
    if request.post? && params[:confirm] && @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => 'queries', :action => 'index'
      return    
        
    end
    respond_to do |format|
      format.js  {
          render:update do |page|
            page << "jQuery('#content_wrapper').html('#{escape_javascript(render:partial=>'queries/new', :locals=>{:query=>@query})}');"

          end
        }
    end
  end
  
  def edit
    if request.post?
      @query.filters = {}
      params[:fields].each do |field|
        @query.add_filter(field, params[:operators][field], params[:values][field])
      end if params[:fields]
      @query.attributes = params[:query]
      @query.project = nil if params[:query_is_for_all]
      @query.is_public = false unless (@query.project && current_role.allowed_to?(:manage_public_queries)) || User.current.admin?
      @query.column_names = nil if params[:default_columns]
      @query.community = current_community
      
      if @query.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :controller => 'queries', :action => 'index',  :query_id => @query
      end
    end
  end


  def update
     @query.filters = {}
      params[:fields].each do |field|
        @query.add_filter(field, params[:operators][field], params[:values][field])
      end if params[:fields]
      @query.attributes = params[:query]
      @query.project = nil if params[:query_is_for_all]
      @query.is_public = false unless (@query.project && current_role.allowed_to?(:manage_public_queries)) || User.current.admin?
      @query.column_names = nil if params[:default_columns]
      if @query.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to :controller => 'queries', :action => 'index',  :query_id => @query
      end
  end

  def destroy
   if @query.destroy
     flash[:notice] = l(:notice_successful_destroy)
     redirect_to :controller => 'queries', :action => 'index', :set_filter => 1
   end
  end

  def projects   
    retrieve_query
    sort_init 'id', 'desc'
    sort_update({'id' => "#{Project.table_name}.id"}.merge(@query.columns.inject({}) {|h, c| h[c.name.to_s] = c.sortable; h}))



    if @query.valid?
      limit = per_page_option
      respond_to do |format|
        format.html { }
        format.atom { }
        format.csv  { limit = Setting.issues_export_limit.to_i }
        format.pdf  { limit = Setting.issues_export_limit.to_i }
      end
      conditions = @query.statement_projects

      @project_count = Project.count( :conditions => conditions)
      @project_pages = Paginator.new self, @project_count, limit, params['page']
      @projects = Project.find :all, :order => sort_clause,
                           :include => [ :parent],
                           :conditions => conditions,
                           :limit  =>  limit,
                           :offset =>  @project_pages.current.offset
      respond_to do |format|
        format.js {
        render:update do |page|
            page << "jQuery('#projects_list').html('#{escape_javascript(render:partial=>'projects/index')}');"
           
          end
        }
      end
    else
      # Send html if the query is not valid
      render(:template => 'queries/index.rhtml', :layout => !request.xhr?)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
    
  end
  
private
  def find_query
    @query = Query.find(params[:id])
    @project = @query.project
    render_403 unless @query.editable_by?(User.current)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def find_optional_project
    @project = Project.find_by_identifier(params[:project_id]) if params[:project_id]
    User.current.allowed_to?(:save_queries, @project, :global => true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Retrieve query from session or build a new query
  def retrieve_query
    if !params[:query_id].blank?     
      @query = Query.find(params[:query_id])
    else
      if params[:set_filter]
        # Give it a name, required to be valid
        @query = Query.new(:name => "_")
        @query.project = nil
        @query.query_type = "project"
        if params[:fields] and params[:fields].is_a? Array
          params[:fields].each do |field|
            @query.add_filter(field, params[:operators][field], params[:values][field])
          end
        else
          @query.available_filters_projects.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        
      else
        @query = Query.new(:name => "_")
        @query.query_type = "project"
        @query.available_filters_projects.keys.each do |field|
          @query.add_short_filter(field, params[field]) if params[field]
        end
      end
    end
  end

  def find_queries
    @projects = Project.find :all,
      :conditions => Project.visible_by(User.current),
      :include => :parent

    query_terms = "(is_public = ? OR user_id = ?) and (project_id IS NULL OR project_id IN (?))"
    query_params = [true, (User.current.logged? ? User.current.id : 0), @projects]

    if current_community
      query_terms << "and (community_id is null or community_id = ?)"
      query_params << current_community.id
    end

    @queries = Query.issues.all(:conditions => [query_terms] + query_params)

#    @queries = Query.issues.all(:conditions => ["(is_public = ? OR user_id = ?) and (project_id IS NULL OR project_id IN (?)) and (community_id IS",
#        true, (User.current.logged? ? User.current.id : 0), @projects])

    @project_queries = Query.projects.all(:conditions => ["(is_public = ? OR user_id = ?) and (project_id IS NULL OR project_id IN (?))",
        true, (User.current.logged? ? User.current.id : 0), @projects])
    end

end
