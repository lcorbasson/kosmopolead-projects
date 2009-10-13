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

class Project < ActiveRecord::Base

  acts_as_taggable
    
  # Project statuses
  STATUS = [['STATUS_ACTIVE', 1], ['STATUS_REJECT', 4], ['STATUS_ARCHIVED', 9]]
  STATUS_ACTIVE     = 1
  STATUS_ARCHIVED   = 9


  belongs_to :status,:class_name=>"ProjectStatus", :foreign_key=>"status_id"
  has_many :project_partners, :include => :partner, :order=> ["#{Partner.table_name}.name"]
  has_many :partners, :through => :project_partners,:order=>["#{Partner.table_name}.name"], :dependent => :destroy
  belongs_to :time_unit, :foreign_key=>"time_units_id"
  has_many :members, :include => [:user, :role], :conditions => "#{User.table_name}.status=#{User::STATUS_ACTIVE}", :order=>["#{Role.table_name}.name ASC, #{User.table_name}.lastname ASC"]
  has_many :users, :through => :members
  has_many :enabled_modules, :dependent => :delete_all
  has_and_belongs_to_many :trackers, :order => "#{Tracker.table_name}.position"
  has_many :issues, :dependent => :destroy, :order => "#{Issue.table_name}.created_on DESC", :include => [:status, :tracker]
  has_one :gallery,:as=>:owned,:conditions=>["owned_type = ?", "project"],:dependent => :destroy

  has_many :funding_lines, :class_name => 'FundingLine', :foreign_key => 'project_id', :dependent => :delete_all
  has_many :relations_from, :class_name => 'ProjectRelation', :foreign_key => 'project_from_id', :dependent => :delete_all
  has_many :relations_to, :class_name => 'ProjectRelation', :foreign_key => 'project_to_id', :dependent => :delete_all
  belongs_to :author,:class_name=>"User",:foreign_key=>"author_id"
  belongs_to :watcher,:class_name=>"User",:foreign_key=>"watcher_id"
  belongs_to :designer,:class_name=>"User",:foreign_key=>"designer_id"
  has_many :issue_changes, :through => :issues, :source => :journals
  has_many :versions, :dependent => :destroy, :order => "#{Version.table_name}.effective_date DESC, #{Version.table_name}.name DESC"
  has_many :time_entries, :dependent => :delete_all
  has_many :queries, :dependent => :delete_all
  has_many :news, :dependent => :delete_all, :include => :author
  has_many :issue_categories, :dependent => :delete_all, :order => "#{IssueCategory.table_name}.name"
  has_many :boards, :dependent => :destroy, :order => "position ASC"
  has_one :repository, :dependent => :destroy
  has_many :changesets, :through => :repository
  has_one :wiki, :dependent => :destroy
  has_many :issues,:dependent=>:delete_all
  has_many :stages,:class_name=>"Issue",:foreign_key=>"issue_types_id",:include=>[:type],:conditions=>["#{IssueType.table_name}.name='STAGE'"]
  has_many :file_attachments,:as=>:container,:conditions=>["container_type = ?", "project"],:dependent => :destroy
  belongs_to :partner

  belongs_to :community
  belongs_to :activity_sector

  # Custom field for the project issues
  has_and_belongs_to_many :issue_custom_fields, 
                          :class_name => 'IssueCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
                          
  acts_as_tree :order => "name", :counter_cache => true,:foreign_key=>"parent_id"

  acts_as_customizable
  acts_as_searchable :columns => ['name', 'description'], :project_key => 'id', :permission => nil
  acts_as_event :title => Proc.new {|o| "#{l(:label_project)}: #{o.name}"},
                :url => Proc.new {|o| {:controller => 'projects', :action => 'show', :id => o.id}},
                :author => nil

#  attr_protected :status, :enabled_module_names
  
  validates_presence_of :name, :identifier, :acronym, :status, :community
  validates_uniqueness_of  :identifier
  validates_associated :repository, :wiki
  validates_length_of :acronym, :maximum => 30
  validates_length_of :homepage, :maximum => 255
  validates_length_of :identifier, :in => 1..20
  validates_format_of :identifier, :with => /^[a-z0-9\-]*$/
  validates_numericality_of :project_cost, :estimated_time, :allow_nil => true
  
  before_destroy :delete_all_members
#  before_save :unarchived
  after_save :create_gallery

  named_scope :has_module, lambda { |mod| { :conditions => ["#{Project.table_name}.id IN (SELECT em.project_id FROM #{EnabledModule.table_name} em WHERE em.name=?)", mod.to_s] } }

  named_scope :visible, :conditions => {:archived => false}
  named_scope :public, :conditions => {:is_public => true}

  after_create :add_member

  validate :role_default

  def role_default
    errors.add_to_base("Il n'y a pas de role par default. Admin => Roles et permissions") if Role.default.nil?
  end

  def identifier=(identifier)
    super unless identifier_frozen?
  end
  
  def identifier_frozen?
    errors[:identifier].nil? && !(new_record? || identifier.blank?)
  end
  
  def issues_with_subprojects(include_subprojects=false)
    conditions = nil
    if include_subprojects
      ids = [id] + child_ids
      conditions = ["#{Project.table_name}.id IN (#{ids.join(',')}) AND #{Project.visible_by}"]
    end
    conditions ||= ["#{Project.table_name}.id = ?", id]
    # Quick and dirty fix for Rails 2 compatibility
    Issue.send(:with_scope, :find => { :conditions => conditions }) do 
      Version.send(:with_scope, :find => { :conditions => conditions }) do
        yield
      end
    end 
  end

  # returns latest created projects
  # non public projects will be returned only if user is a member of those
  def self.latest(user=nil, count=5)
    find(:all, :limit => count, :conditions => visible_by(user), :order => "created_on DESC")	
  end	

  def self.visible_by(user=nil, community = nil)
    user ||= User.current

    query = ["#{Project.table_name}.archived = ?"]
    params = [false]

    if community
      query << "#{Project.table_name}.community_id = ?"
      params << community.id
    end

# soucis avec ce bout de code, erreur SQL si aucune membership
#    unless user.admin?
#      query << "#{Project.table_name}.id in (?)"
#      params << user.memberships.collect(&:project_id)
#    end

    unless user.admin?
      query << "#{Project.table_name}.id in (select project_id from #{Member.table_name} where user_id = ?)"
      params << user.id
    end

    [query.join(" AND ")] + params

#    if community
#      "#{Project.table_name}.archived = false AND #{Project.table_name}.community_id = #{community.id}"
#    else
#      if user && user.admin?
#        return "#{Project.table_name}.archived = false"
#      elsif user && user.memberships.any?
#        return "#{Project.table_name}.archived = false AND (#{Project.table_name}.is_public = #{connection.quoted_true} or #{Project.table_name}.id IN (#{user.memberships.collect{|m| m.project_id}.join(',')}))"
#      else
#        return "#{Project.table_name}.archived = false AND #{Project.table_name}.is_public = #{connection.quoted_true}"
#      end
#    end
  end
  
  def self.allowed_to_condition(user, permission, options={})
    statements = []
    base_statement = "#{Project.table_name}.archived = false"
    if perm = Redmine::AccessControl.permission(permission)
      unless perm.project_module.nil?
        # If the permission belongs to a project module, make sure the module is enabled
        base_statement << " AND EXISTS (SELECT em.id FROM #{EnabledModule.table_name} em WHERE em.name='#{perm.project_module}' AND em.project_id=#{Project.table_name}.id)"
      end
    end
    if options[:project]
      project_statement = "#{Project.table_name}.id = #{options[:project].id}"
      project_statement << " OR #{Project.table_name}.parent_id = #{options[:project].id}" if options[:with_subprojects]
      base_statement = "(#{project_statement}) AND (#{base_statement})"
    end
    if user.admin?
      # no restriction
    else
      statements << "1=0"
      if user.logged?
        statements << "#{Project.table_name}.is_public = #{connection.quoted_true}" if Role.non_member.allowed_to?(permission)
        allowed_project_ids = user.memberships.select {|m| m.role.allowed_to?(permission)}.collect {|m| m.project_id}
        statements << "#{Project.table_name}.id IN (#{allowed_project_ids.join(',')})" if allowed_project_ids.any?
      elsif Role.anonymous.allowed_to?(permission)
        # anonymous user allowed on public project
        statements << "#{Project.table_name}.is_public = #{connection.quoted_true}" 
      else
        # anonymous user is not authorized
      end
    end
    statements.empty? ? base_statement : "((#{base_statement}) AND (#{statements.join(' OR ')}))"
  end
  
  def project_condition(with_subprojects)
    cond = "#{Project.table_name}.id = #{id}"
    cond = "(#{cond} OR #{Project.table_name}.parent_id = #{id})" if with_subprojects
    cond
  end
  
#  def self.find(*args)
#    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
#      project = find_by_identifier(*args)
#      raise ActiveRecord::RecordNotFound, "Couldn't find Project with identifier=#{args.first}" if project.nil?
#      project
#    else
#      super
#    end
#  end
 
  def to_param
    # id is used for projects with a numeric identifier (compatibility)
    @to_param ||= (identifier.to_s =~ %r{^\d*$} ? id : identifier)
  end
  
  def active?
    self.status == STATUS_ACTIVE
  end

  def archived
    self.archived
  end

 
  
  def archive
    # Archive subprojects if any
    children.each do |subproject|
      subproject.archive
    end
    update_attribute :archived, true
  end
  
  def unarchive
    return false if parent && !parent.active?
    update_attribute :archived, false
  end

  def unarchived
    self.archived = false
  end
  
  def active_children
    children.select {|child| child.active?}
  end
  
  # Returns an array of the trackers used by the project and its sub projects
  def rolled_up_trackers
    @rolled_up_trackers ||=
      Tracker.find(:all, :include => :projects,
                         :select => "DISTINCT #{Tracker.table_name}.*",
                         :conditions => ["#{Project.table_name}.id = ? OR #{Project.table_name}.parent_id = ?", id, id],
                         :order => "#{Tracker.table_name}.position")
  end
  
  # Deletes all project's members
  def delete_all_members
    Member.delete_all(['project_id = ?', id])
  end

  def create_gallery
    Gallery.create(:owned_type=>"project", :owned_id=>self.id)
  end
  
  # Users issues can be assigned to
  def assignable_users
    members.select {|m| m.role.assignable?}.collect {|m| m.user}.sort
  end
  
  # Returns the mail adresses of users that should be always notified on project events
  def recipients
    members.select {|m| m.mail_notification? || m.user.mail_notification?}.collect {|m| m.user.mail}
  end
  
  # Returns an array of all custom fields enabled for project issues
  # (explictly associated custom fields and custom fields enabled for all projects)
  def all_issue_custom_fields
    @all_issue_custom_fields ||= (IssueCustomField.for_all + issue_custom_fields).uniq.sort
  end
  
  def project
    self
  end
  
  def <=>(project)
    name.downcase <=> project.name.downcase
  end
  
  def to_s
    name
  end
  
  # Returns a short description of the projects (first lines)
  def short_description(length = 255)
    description.gsub(/^(.{#{length}}[^\n]*).*$/m, '\1').strip if description
  end
  
  def allows_to?(action)
    if action.is_a? Hash
      allowed_actions.include? "#{action[:controller]}/#{action[:action]}"
    else
      allowed_permissions.include? action
    end
  end
  
  def module_enabled?(module_name)
    module_name = module_name.to_s
    enabled_modules.detect {|m| m.name == module_name}
  end
  
  def enabled_module_names=(module_names)
    enabled_modules.clear
    module_names = [] unless module_names && module_names.is_a?(Array)
    module_names.each do |name|
      enabled_modules << EnabledModule.new(:name => name.to_s)
    end
  end
  
  # Returns an auto-generated project identifier based on the last identifier used
  def self.next_identifier
    p = Project.find(:first, :order => 'id DESC')
    p.nil? ? nil : p.identifier.to_s.succ
  end

  def time_unit_label
     case self.time_unit.label
      when "hours"
        l(:field_hours)
      when "days"
        l(:field_days)
      when "weeks"
        l(:field_weeks)
      when "months"
        l(:field_months)
      end
  end
  def level
    parent = self.parent
    project = self
    level = 0
    while(!parent.nil?)
      project = parent
      parent = project.parent
      level= level+1
    end
    return level
  end


   def self.tags_json
    rows = []
    Tag.all.each  do  |t|
      rows << {:caption => t.name, :value => t.name}
    end
    return rows.to_json
  end

   def relations
    relations_from+relations_to
  end

   def self.find_funding_col_names_project(project)
     grid_col_names = []
      project.funding_custom_fields.each do |field|
        grid_col_names<<field.name
      end
      grid_col_names.to_json
   end

   def self.find_funding_col_model_project(project)
     grid_col_model = []    
     project.funding_custom_fields.each do |field|
        grid_col_model<< {:name=>"#{field.name}",:index=>"#{field.name}",:editable=>true,:editoptions=>{:readonly=>false,:size=>10}}
     end   
     grid_col_model.to_json   
   end

   def completed_percent
    @completed_percent = 0
    self.issues.issues.each do |issue|
      if issue.closed?
        @completed_percent += 1
      else
        @completed_percent += issue.done_ratio
      end
     end
     if @completed_percent > 0
       @completed_percent = @completed_percent/self.issues.issues.count
     end
     return @completed_percent
   end

  def add_member
    unless author_id.nil? && id.nil?
      unless Role.default.nil?
        Member.create(:user_id => author_id, :project_id => id, :role_id => "#{Role.default.id}")
        puts "partner_id = #{partner_id} #{partner_id.nil?}"
      end
    end
  end
   

protected
  def validate
    #errors.add(parent_id, " must be a root project") if parent and parent.parent
    errors.add_to_base("A project with subprojects can't be a subproject") if parent and children.size > 0
    errors.add(:identifier, :activerecord_error_invalid) if !identifier.blank? && identifier.match(/^\d*$/)
  end
  
private
  def allowed_permissions
    @allowed_permissions ||= begin
      module_names = enabled_modules.collect {|m| m.name}
      Redmine::AccessControl.modules_permissions(module_names).collect {|p| p.name}
    end
  end

  def allowed_actions
    @actions_allowed ||= allowed_permissions.inject([]) { |actions, permission| actions += Redmine::AccessControl.allowed_actions(permission) }.flatten
  end

end
