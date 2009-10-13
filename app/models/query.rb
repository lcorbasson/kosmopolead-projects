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

class QueryColumn  
  attr_accessor :name, :sortable, :default_order
  include GLoc
  
  def initialize(name, options={})
    self.name = name
    self.sortable = options[:sortable]
    self.default_order = options[:default_order]
  end
  
  def caption
    set_language_if_valid(User.current.language)
    l("field_#{name}")
  end
end

class QueryCustomFieldColumn < QueryColumn

  def initialize(custom_field)
    self.name = "cf_#{custom_field.id}".to_sym
    self.sortable = false
    @cf = custom_field
  end
  
  def caption
    @cf.name
  end
  
  def custom_field
    @cf
  end
end

class QueryIssueTypeColumn < QueryColumn

  def initialize(name, sort)
    self.name = name
    self.sortable = false   
  end

  
end


class Query < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  belongs_to :community
  serialize :filters
  serialize :column_names
  
  attr_protected :project_id, :user_id
  
  validates_presence_of :name, :on => :save
  validates_length_of :name, :maximum => 255

  named_scope :projects, :conditions=>["query_type= ?", "project"], :order => "name ASC"
  named_scope :issues, :conditions=>["query_type= ?", "issue"], :order => "name ASC"
    
  @@operators = { "="   => :label_equals, 
                  "!"   => :label_not_equals,
                  "o"   => :label_open_issues,
                  "c"   => :label_closed_issues,
                  "!*"  => :label_none,
                  "*"   => :label_all,
                  ">="   => '>=',
                  "<="   => '<=',
                  "<t+" => :label_in_less_than_date,
                  ">t+" => :label_in_more_than_date,
                  "t+"  => :label_in,
                  "t"   => :label_today,
                  "w"   => :label_this_week,
                  ">t-" => :label_less_than_ago_date,
                  "<t-" => :label_more_than_ago_date,
                  "t-"  => :label_ago_date,
                  "~"   => :label_contains,
                  "!~"  => :label_not_contains }

  cattr_reader :operators

#    @@operators_by_filter_type = { :list => [ "=", "!" ],
#                                 :list_status => [ "=", "!", "*" ],
#                                 :list_optional => [ "=", "!", "!*", "*" ],
#                                 :list_multiple => [ "=", "!", "!*", "*" ],
#                                 :list_subprojects => [ "*", "!*", "=" ],
#                                 :date => [ "<t+", ">t+", "t+", "t", "w", ">t-", "<t-", "t-" ],
#                                 :date_past => [ ">t-", "<t-", "t-", "t", "w" ],
#                                 :string => [ "=", "~", "!", "!~" ],
#                                 :text => [  "~", "!~" ],
#                                 :integer => [ "=", ">=", "<=", "!*", "*" ] }
  @@operators_by_filter_type = { :list_equal => ["=", "!"],
                                 :list => [ "=", "!" ],
                                 :list_status => [ "=", "!", "*" ],
                                 :list_optional => [ "=", "!", "!*", "*" ],
                                 :list_multiple => [ "=", "!", "!*", "*" ],
                                 :list_subprojects => [ "*", "!*", "=" ],
                                 :date => [ "<t+", ">t+", "t", "w", "t-" ],
                                 :date_past => [ ">t-", "<t-", "t-", "t", "w" ],
                                 :string => [ "=", "~", "!", "!~" ],
                                 :text => [  "~", "!~" ],
                                 :integer => [ "=", ">=", "<=", "!*", "*" ] }

  cattr_reader :operators_by_filter_type

  @@available_columns = [
    QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject"),
    QueryColumn.new(:project, :sortable => "#{Project.table_name}.name"),
    QueryColumn.new(:tracker, :sortable => "#{Tracker.table_name}.position"),
    QueryColumn.new(:status, :sortable => "#{IssueStatus.table_name}.position"),
    QueryColumn.new(:priority, :sortable => "#{Enumeration.table_name}.position", :default_order => 'desc'),
    QueryColumn.new(:author),
    QueryColumn.new(:assigned_to, :sortable => "#{User.table_name}.lastname"),
    QueryColumn.new(:updated_on, :sortable => "#{Issue.table_name}.updated_on", :default_order => 'desc'),
    QueryColumn.new(:category, :sortable => "#{IssueCategory.table_name}.name"),
    QueryColumn.new(:fixed_version, :sortable => "#{Version.table_name}.effective_date", :default_order => 'desc'),
    QueryColumn.new(:start_date, :sortable => "#{Issue.table_name}.start_date"),
    QueryColumn.new(:due_date, :sortable => "#{Issue.table_name}.due_date"),
    QueryColumn.new(:estimated_hours, :sortable => "#{Issue.table_name}.estimated_hours"),
    QueryColumn.new(:done_ratio, :sortable => "#{Issue.table_name}.done_ratio"),
    QueryColumn.new(:created_on, :sortable => "#{Issue.table_name}.created_on", :default_order => 'desc'),
    QueryIssueTypeColumn.new(:issue_type, :sortable => "#{IssueType.table_name}.name", :default_order => 'desc'),
  ]
  cattr_reader :available_columns


  @@available_columns_project = [
    QueryColumn.new(:name, :sortable => "#{Project.table_name}.name"),
    QueryColumn.new(:acronym, :sortable => "#{Project.table_name}.acronym"),
    QueryColumn.new(:identifier, :sortable => "#{Project.table_name}.identifier"),
    QueryColumn.new(:status, :sortable => "#{ProjectStatus.table_name}.status_label"),
    QueryColumn.new(:estimated_time, :sortable => "#{Project.table_name}.estimated_time"),
    QueryColumn.new(:author, :sortable => "#{User.table_name}.lastname"),
    QueryColumn.new(:watcher, :sortable => "#{User.table_name}.lastname"),
    QueryColumn.new(:designer, :sortable => "#{User.table_name}.lastname"),
    QueryColumn.new(:project_cost, :sortable => "#{Project.table_name}.project_cost"),
    QueryColumn.new(:created_on, :sortable => "#{Project.table_name}.created_on", :default_order => 'desc')
   
  ]
  cattr_reader :available_columns_project


  
  def initialize(attributes = nil)
    super attributes
    self.filters ={}
    set_language_if_valid(User.current.language)
  end
  
  def after_initialize
    # Store the fact that project is nil (used in #editable_by?)
    @is_for_all = project.nil?
  end
  
  def validate
    filters.each_key do |field|
      errors.add label_for(field), :activerecord_error_blank unless 
          # filter requires one or more values
          (values_for(field) and !values_for(field).first.blank?) or 
          # filter doesn't require any value
          ["o", "c", "!*", "*", "t", "w"].include? operator_for(field)
    end if filters
  end
  
  def editable_by?(user)
    return false unless user
    # Admin can edit them all and regular users can edit their private queries
    return true if user.admin? || (!is_public && self.user_id == user.id)
    # Members can not edit public queries that are for all project (only admin is allowed to)
    is_public && !@is_for_all && user.allowed_to?(:manage_public_queries, project)
  end
  
  def available_filters
    return @available_filters if @available_filters
    
    trackers = project.nil? ? Tracker.find(:all, :order => 'position') : project.rolled_up_trackers
    
    @available_filters = { "status" => { :type => :list_status, :order => 1, :values => IssueStatus.find(:all, :order => 'position').collect{|s| [s.name, s.id.to_s] } },       
                           "tracker_id" => { :type => :list, :order => 2, :values => trackers.collect{|s| [s.name, s.id.to_s] } },                                                                                                                
                           "priority_id" => { :type => :list, :order => 3, :values => Enumeration.find(:all, :conditions => ['opt=?','IPRI'], :order => 'position').collect{|s| [s.name, s.id.to_s] } },
                           "subject" => { :type => :text, :order => 8 },  
                           "created_on" => { :type => :date_past, :order => 9 },                        
                           "updated_on" => { :type => :date_past, :order => 10 },
                           "start_date" => { :type => :date, :order => 11 },
                           "due_date" => { :type => :date, :order => 12 },
                           "estimated_hours" => { :type => :integer, :order => 13 },
                           "done_ratio" =>  { :type => :integer, :order => 14 }}
    
    user_values = []
    user_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    if project
      user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
    else
      # members of the user's projects
      user_values += User.current.projects.sort.collect(&:users).flatten.uniq.sort.collect{|s| [s.name, s.id.to_s] }
    end
    @available_filters["assigned_to_id"] = { :type => :list, :order => 4, :values => user_values } unless user_values.empty?
    @available_filters["author_id"] = { :type => :list, :order => 5, :values => user_values } unless user_values.empty?

    if project
      # project specific filters
      unless @project.issue_categories.empty?
        @available_filters["category_id"] = { :type => :list_optional, :order => 6, :values => @project.issue_categories.collect{|s| [s.name, s.id.to_s] } }
      end
      unless @project.versions.empty?
        @available_filters["fixed_version_id"] = { :type => :list_optional, :order => 7, :values => @project.versions.sort.collect{|s| [s.name, s.id.to_s] } }
      end
      unless @project.active_children.empty?
        @available_filters["subproject_id"] = { :type => :list_subprojects, :order => 13, :values => @project.active_children.collect{|s| [s.name, s.id.to_s] } }
      end
      add_custom_fields_filters(@project.all_issue_custom_fields)
    else
      # si on est dans une communauté
      if Community.current
        # on récupère les CustomField de la communauté
        custom_fields = Community.current.project_custom_fields
      else
        # sinon ceux de toutes les communautés de l'utilisateur
        custom_fields = User.current.communities.collect(&:project_custom_fields).flatten.uniq
      end

      # global filters for cross project issue list
      add_custom_fields_filters(custom_fields.select{|f| f.is_filter && f.is_for_all })
#      add_custom_fields_filters(IssueCustomField.find(:all, :conditions => {:community_id => Community.current, :is_filter => true, :is_for_all => true}))
    end
    @available_filters
  end


  def available_filters_projects
    return @available_filters_projects if @available_filters_projects    

    if Community.current
      users = Community.current.users
      project_statuses = Community.current.project_statuses
      custom_fields = Community.current.project_custom_fields
      partners = Community.current.partners
      projects = Community.current.projects
    else
      users = User.current.communities.collect(&:users).flatten.uniq
      project_statuses = User.current.communities.collect(&:project_statuses).flatten.uniq
      custom_fields = User.current.communities.collect(&:project_custom_fields).flatten.uniq
      partners = User.current.communities.collect(&:partners).flatten.uniq
      projects = User.current.communities.collect(&:projects).flatten.uniq
    end
    designers = []
    watchers = []
    authors = []
    tags = []
    projects.each  do |p|
      designers << p.designer unless p.designer.nil?
      watchers << p.watcher unless p.watcher.nil?
      authors << p.author unless p.author.nil?
      p.tags.each do |tag|
        exist = false
        tags.each do |t|         
            exist = true if t.name.eql?(tag.name)
        end
        if !exist
          tags << tag
        end
      end
    end
    funding_lines = projects.collect{|p| p.funding_lines}.flatten
    
    @available_filters_projects = {
      "status_id" => { :type => :list_status, :order => 1, :values => project_statuses.collect{|s| [s.status_label, s.id.to_s] } },
      "designer_id" => { :type => :list_equal, :order => 3, :values => designers.sort.collect{|d| [d.name,d.id.to_s]}.uniq},
      "author_id" => { :type => :list_equal, :order => 2, :values => authors.sort.collect{|a| [a.name, a.id.to_s]}.uniq},
      "watcher_id" => { :type => :list_equal, :order => 4, :values => watchers.sort.collect{|w| [w.name, w.id.to_s]}.uniq},
      "members" => { :type => :list_equal, :order => 5, :values => users.sort.collect{|u| [u.name, u.id.to_s] }},
      "partners" => { :type => :list_equal, :order => 6, :values => partners.collect{|u| [u.name, u.id.to_s] }},
      "tag" => { :type => :list_equal, :order => 7, :values => tags.collect{|t| [t.name, t.id.to_s]} },
      "aap" => { :type => :list_equal, :order => 8, :values => funding_lines.delete_if{|x| x.aap.nil?}.collect{|fl| [fl.aap, fl.aap]}.uniq.sort },
      "backer" => { :type => :list_equal, :order => 9, :values => funding_lines.delete_if{|x| x.backer.nil?}.collect{|fl| [fl.backer, fl.backer]}.uniq.sort },
      "backer_correspondent" => { :type => :list_equal, :order => 10, :values => funding_lines.delete_if{|x| x.backer_correspondent.nil?}.collect{|fl| [fl.backer_correspondent, fl.backer_correspondent]}.uniq.sort },
      "funding_type" => { :type => :list_equal, :order => 11, :values => funding_lines.delete_if{|x| x.funding_type.nil?}.collect{|fl| [fl.funding_type, fl.funding_type] unless fl.funding_type.nil?}.uniq.sort },
      "beneficiary" => { :type => :list_equal, :order => 12, :values => funding_lines.delete_if{|x| x.beneficiary.nil?}.collect{|fl| [fl.beneficiary, fl.beneficiary]}.uniq.sort }
    }

    add_custom_fields_filters_projects(custom_fields)
    
    @available_filters_projects
  end

  
  def add_filter(field, operator, values)
    # values must be an array
    return unless values and values.is_a? Array # and !values.first.empty?
    # check if field is defined as an available filter
   
      filter_options = available_filters[field]
      # check if operator is allowed for that filter
      #if @@operators_by_filter_type[filter_options[:type]].include? operator
      #  allowed_values = values & ([""] + (filter_options[:values] || []).collect {|val| val[1]})
      #  filters[field] = {:operator => operator, :values => allowed_values } if (allowed_values.first and !allowed_values.first.empty?) or ["o", "c", "!*", "*", "t"].include? operator
      #end
      filters[field] = {:operator => operator, :values => values }
   
  end
  
  def add_short_filter(field, expression)
    return unless expression
    parms = expression.scan(/^(o|c|\!|\*)?(.*)$/).first
    add_filter field, (parms[0] || "="), [parms[1] || ""]
  end

   
  def has_filter?(field)
    filters and filters[field]
  end
  
  def operator_for(field)
    has_filter?(field) ? filters[field][:operator] : nil
  end
  
  def values_for(field)
    has_filter?(field) ? filters[field][:values] : nil
  end
  
  def label_for(field)
    label = available_filters[field][:name] if available_filters.has_key?(field)
    label ||= field.gsub(/\_id$/, "")
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = Query.available_columns
    @available_columns += (project ? 
                            project.all_issue_custom_fields :
                            IssueCustomField.find(:all, :conditions => {:is_for_all => true})
                           ).collect {|cf| QueryCustomFieldColumn.new(cf) }


  end

  def available_columns_project
    return @available_columns_project if @available_columns_project
    @available_columns_project = Query.available_columns_project
    @available_columns_project += (Community.current.project_custom_fields.collect {|cf| QueryCustomFieldColumn.new(cf) })


  end
  
  def columns
    if has_default_columns?
      available_columns.select do |c|
        # Adds the project column by default for cross-project lists
        Setting.issue_list_default_columns.include?(c.name.to_s) || (c.name == :project && project.nil?)
      end
    else
      # preserve the column_names order
      column_names.collect {|name| available_columns.find {|col| col.name == name}}.compact
    end
  end

  def columns_project
    if has_default_columns?
      available_columns_project.select do |c|
        # Adds the project column by default for cross-project lists
        Setting.project_list_default_columns.include?(c.name.to_s) || (c.name == :project && project.nil?)
      end
    else
      # preserve the column_names order
      column_names.collect {|name| available_columns.find {|col| col.name == name}}.compact
    end
  end

  
  def column_names=(names)
    names = names.select {|n| n.is_a?(Symbol) || !n.blank? } if names
    names = names.collect {|n| n.is_a?(Symbol) ? n : n.to_sym } if names
    write_attribute(:column_names, names)
  end
  
  def has_column?(column)
    column_names && column_names.include?(column.name)
  end
  
  def has_default_columns?
    column_names.nil? || column_names.empty?
  end


  
  def project_statement
    project_clauses = []

    project_clauses << "#{Project.table_name}.id = %d" % project.id

   
    project_clauses.join(' AND ')
  end

  def statement
    # filters clauses
    filters_clauses = []
    filters.each_key do |field|
      next if field == "subproject_id"
      
      v = values_for(field).clone
      next unless v and !v.empty?
            
      sql = ''      
      is_custom_filter = false    
      if field =~ /^cf_(\d+)$/
        # custom field
        db_table = CustomValue.table_name
        db_field = 'value'
        is_custom_filter = true
        sql << "#{Issue.table_name}.id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.customized_type='Issue' AND #{db_table}.customized_id=#{Issue.table_name}.id AND #{db_table}.custom_field_id=#{$1} WHERE "
      else
        if (field == "assigned_to_id")
          # custom field
          db_table = Assignment.table_name
          db_field = 'user_id'
          sql << "#{Issue.table_name}.id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.issue_id=#{Issue.table_name}.id WHERE  "
        else
           db_table = Issue.table_name
           sql << '('
          if (field == "status")
            db_field = 'status_id'
          else
            # regular field
            db_field = field
          end
        end
      end
      
      # "me" value subsitution
      if %w(assigned_to_id author_id).include?(field) 
        v.push(User.current.logged? ? User.current.id.to_s : "0") if v.delete("me")
      end
      
      sql = sql + sql_for_field(field, v, db_table, db_field, is_custom_filter)
      
      sql << ')'
      filters_clauses << sql
    end
    if self.query_type == "issue"
      (filters_clauses << project_statement).join(' AND ')
    else
      filters_clauses.join(' AND ')
    end
  end


  def statement_projects
     # filters clauses
    filters_clauses = []
    filters.each_key do |field|  

      v = values_for(field).clone
      next unless v and !v.empty?

      sql = ''
     if field =~ /^cf_(\d+)$/
          # custom field
          db_table = CustomValue.table_name
          db_field = 'value'
          is_custom_filter = true         
          sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.customized_type='Project' AND #{db_table}.customized_id=#{Project.table_name}.id AND #{db_table}.custom_field_id=#{$1} WHERE "

      else
         db_field = field
        case field
          when "status_id"
            db_table = ProjectStatus.table_name
            sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{db_table} ON #{db_table}.id=#{Project.table_name}.status_id WHERE #{Project.table_name}.status_id=#{v}"
          when "members"
            if ((operator_for field).to_s == '=')
              sql << "projects.archived=false AND projects.id IN (SELECT project_id FROM members WHERE #{v.map{|value| "user_id = #{value}"}.join(' OR ')})"
           else
              sql << "projects.archived=false AND projects.id NOT IN (SELECT project_id FROM members WHERE #{v.map{|value| "user_id = #{value}"}.join(' OR ')})"
           end
          when "partners"
            if ((operator_for field).to_s == '=')
              sql << "projects.archived=false AND projects.id IN (SELECT project_id FROM project_partners WHERE #{v.map{|value| "partner_id = #{value}"}.join(' OR ')})"
            else
              sql << "projects.archived=false AND projects.id NOT IN (SELECT project_id FROM project_partners WHERE #{v.map{|value| "partner_id = #{value}"}.join(' OR ')})"
            end
          when "tag"
             sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{Tagging.table_name} ON #{Tagging.table_name}.taggable_id=#{Project.table_name}.id AND #{Tagging.table_name}.taggable_type='Project' LEFT OUTER JOIN #{Tag.table_name} ON #{Tag.table_name}.id = #{Tagging.table_name}.tag_id WHERE #{Tag.table_name}.id IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
          when "aap"
             sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{FundingLine.table_name} ON #{FundingLine.table_name}.project_id=#{Project.table_name}.id WHERE aap IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
          when "backer"
            sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{FundingLine.table_name} ON #{FundingLine.table_name}.project_id=#{Project.table_name}.id WHERE backer IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
          when "backer_correspondent"
            sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{FundingLine.table_name} ON #{FundingLine.table_name}.project_id=#{Project.table_name}.id WHERE backer_correspondent IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
         when "funding_type"
            sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{FundingLine.table_name} ON #{FundingLine.table_name}.project_id=#{Project.table_name}.id WHERE funding_type IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
         when "beneficiary"
            sql << "#{Project.table_name}.id IN (SELECT #{Project.table_name}.id FROM #{Project.table_name} LEFT OUTER JOIN #{FundingLine.table_name} ON #{FundingLine.table_name}.project_id=#{Project.table_name}.id WHERE beneficiary IN (#{v.collect{|val| "'#{connection.quote_string(val)}'"}.join(",")})"
         else
            db_table = Project.table_name
        end

         if (field != "status_id" && field != "members" && field != "partners" && field != "tag" && field != "aap" && field != "backer" && field != "backer_correspondent" && field != "beneficiary" && field != "funding_type")
            sql << '('
         end
         
      end

     if (field != "status_id" && field != "members" && field != "partners" && field != "tag" && field != "aap" && field != "backer" && field != "backer_correspondent" && field != "beneficiary" && field != "funding_type")
        sql = sql + sql_for_field_projects(field, v, db_table, db_field, is_custom_filter)
     end
     if (field != "members" && field != "partners" )
       sql << ')'
     end
       filters_clauses << sql       
    end
    filters_clauses.join(' AND ')   
  end
  
  
  private
  
  # Helper method to generate the WHERE sql for a +field+ with a +value+
  def sql_for_field(field, value, db_table, db_field, is_custom_filter)
    sql = ''
    case operator_for field
    when "="
      sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
    when "!"
      sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
    when "!*"
      sql = "#{db_table}.#{db_field} IS NULL"
      sql << " OR #{db_table}.#{db_field} = ''" if is_custom_filter
    when "*"
      sql = "#{db_table}.#{db_field} IS NOT NULL"
      sql << " AND #{db_table}.#{db_field} <> ''" if is_custom_filter
    when ">="
      sql = "#{db_table}.#{db_field} >= #{value.first}"
    when "<="
      sql = "#{db_table}.#{db_field} <= #{value.first}"
    when "o"
      sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_false}" if field == "status_id"
    when "c"
      sql = "#{IssueStatus.table_name}.is_closed=#{connection.quoted_true}" if field == "status_id"
    when ">t-"
      sql = date_range_clause(db_table, db_field, value, nil)
    when "<t-"
      sql = date_range_clause(db_table, db_field, nil, value)
    when "t-"
      unless is_custom_filter
        sql = date_range_clause(db_table, db_field, value, (Date.parse(value.first.delete("&quot;")) + 1).strftime("%Y-%m-%d"))
      else
        sql = date_range_clause_custom_field(db_table, db_field, value, field)
      end
    when ">t+"
      unless is_custom_filter
        sql = date_range_clause(db_table, db_field, value, nil)
      else
        sql = date_range_clause_custom_field(db_table, db_field, value, field)
      end
    when "<t+"
      unless is_custom_filter
        sql = date_range_clause(db_table, db_field, nil, value)
      else
        sql = date_range_clause_custom_field(db_table, db_field, value, field)
      end
    when "t+"
      sql = date_range_clause(db_table, db_field, value, value)
    when "t"
      unless is_custom_filter
        sql = date_range_clause(db_table, db_field, Date.today, Date.today + 1)
      else
        sql = date_range_clause_custom_field(db_table, db_field, value, field)
      end
    when "w"
      unless is_custom_filter
        from = l(:general_first_day_of_week) == '7' ?
        # week starts on sunday
        ((Date.today.cwday == 7) ? Time.now.at_beginning_of_day : Time.now.at_beginning_of_week - 1.day) :
          # week starts on monday (Rails default)
          Date.today.at_beginning_of_week
        sql = "#{db_table}.#{db_field} BETWEEN '%s' AND '%s'" % [from, from + 7.day]
      else
        sql = date_range_clause_custom_field(db_table, db_field, value, field)
      end
    when "~"
      sql = "#{db_table}.#{db_field} LIKE '%#{connection.quote_string(value.first)}%'"
    when "!~"
      sql = "#{db_table}.#{db_field} NOT LIKE '%#{connection.quote_string(value.first)}%'"
    end
  
    return sql
  end

  def sql_for_field_projects(field, value, db_table, db_field, is_custom_filter)
    sql = ''
    case operator_for field
    when "="
      sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
    when "!"
      sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
    when "!*"
      sql = "#{db_table}.#{db_field} IS NULL"
      sql << " OR #{db_table}.#{db_field} = ''" if is_custom_filter
    when "*"
      sql = "#{db_table}.#{db_field} IS NOT NULL"
      sql << " AND #{db_table}.#{db_field} <> ''" if is_custom_filter
    when ">="
      sql = "#{db_table}.#{db_field} >= #{value}"
    when "<="
      sql = "#{db_table}.#{db_field} <= #{value}"
    when "o"
      sql = "#{Project.table_name}.status=1" if field == "status"
    when "c"
      sql = "#{Project.table_name}.status=0" if field == "status"
    when ">t-"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "<t-"
      sql = date_range_clause_custom_field(db_table, db_field,value, field)
    when "t-"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when ">t+"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "<t+"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "t+"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "t"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "w"
      sql = date_range_clause_custom_field(db_table, db_field, value, field)
    when "~"
      sql = "#{db_table}.#{db_field} LIKE '%#{connection.quote_string(value)}%'"
    when "!~"
      sql = "#{db_table}.#{db_field} NOT LIKE '%#{connection.quote_string(value)}%'"
    end
    return sql
  end
  
  def add_custom_fields_filters(custom_fields)
    @available_filters ||= {}
    
    custom_fields.select(&:is_filter?).each do |field|
      case field.field_format
      when "text"
        options = { :type => :text, :order => 20 }
      when "list"
        options = { :type => :list_optional, :values => field.possible_values, :order => 20}
      when "multi_list"
        options = { :type => :list_multiple, :values => field.possible_values, :order => 20}
      when "date"
        options = { :type => :date, :order => 20 }
      when "bool"
        options = { :type => :list, :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]], :order => 20 }
      else
        options = { :type => :string, :order => 20 }
      end
      @available_filters["cf_#{field.id}"] = options.merge({ :name => field.name })
    end
  end

  def add_custom_fields_filters_projects(custom_fields)
    @available_filters ||= {}

    custom_fields.select(&:is_filter?).each do |field|
      case field.field_format
      when "text"
        options = { :type => :text, :order => 20 }
      when "list"
        options = { :type => :list_optional, :values => field.possible_values, :order => 20}
      when "multi_list"
        options = { :type => :list_multiple, :values => field.possible_values, :order => 20}
      when "date"
        options = { :type => :date, :order => 20 }
      when "bool"
        options = { :type => :list, :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]], :order => 20 }
      else
        options = { :type => :string, :order => 20 }
      end
      @available_filters_projects["cf_#{field.id}"] = options.merge({ :name => field.name })
    end
  end
  
  # Returns a SQL clause for a date or datetime field.
  def date_range_clause(table, field, from, to,yaml = false)
    s = []
     if yaml
      if from
        s << ("#{table}.#{field} > '%s'" % "--- #{from}")
      end
      if to
        s << ("#{table}.#{field} < '%s'" % "--- #{to}")
      end
     else
        if from
        s << ("#{table}.#{field} > '%s'" % from)
      end
      if to
        s << ("#{table}.#{field} < '%s'" % to)
      end
     end
    s.join(' AND ')
  end

  def date_range_clause_custom_field(table, db_field, from, field)
    s = []

    case operator_for field
      when "t-"
        s << ("#{table}.#{db_field} > '%s'" % "--- #{(Date.parse(from.first.delete("&quot;")) - 1).strftime("%Y-%m-%d")}")
        s << ("#{table}.#{db_field} < '%s'" % "--- #{(Date.parse(from.first.delete("&quot;")) + 1).strftime("%Y-%m-%d")}")
      when ">t+"
        s << ("#{table}.#{db_field} > '%s'" % "--- #{from}")
      when "<t+"
        s << ("#{table}.#{db_field} < '%s'" % "--- #{from}")
      when "t"
        s << ("#{table}.#{db_field} > '%s'" % "--- #{(Date.today-1).strftime("%Y-%m-%d")}")
        s << ("#{table}.#{db_field} < '%s'" % "--- #{(Date.today+1).strftime("%Y-%m-%d")}")
      when "w"
        from = l(:general_first_day_of_week) == '7' ?
        # week starts on sunday
        ((Date.today.cwday == 7) ? Time.now.at_beginning_of_day : Time.now.at_beginning_of_week - 1.day) :
          # week starts on monday (Rails default)
          Time.now.at_beginning_of_week
        s << "#{table}.#{db_field} BETWEEN '%s' AND '%s'" % ["--- #{from.strftime('%Y-%m-%d')}", "--- #{(from + 7.day).strftime('%Y-%m-%d')}"]
    end
    s << ("#{table}.#{db_field} is not null")
    s.join(' AND ')
  end

end
