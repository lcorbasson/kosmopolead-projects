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

require 'csv'

@@top = nil

module IssuesHelper
  include ApplicationHelper

  def render_issue_tooltip(issue)
    @cached_label_start_date ||= l(:field_start_date)
    @cached_label_due_date ||= l(:field_due_date)
    @cached_label_assigned_to ||= l(:field_assigned_to)
    @cached_label_priority ||= l(:field_priority)
    
    tooltip = link_to_issue(issue) + ": #{h(issue.subject)}<br /><br />" +
      "<strong>#{@cached_label_start_date}</strong>: #{format_date(issue.start_date)}<br />" +
      "<strong>#{@cached_label_due_date}</strong>: #{format_date(issue.due_date)}<br />" 


    if issue.is_issue?
      tooltip += "<strong>#{@cached_label_assigned_to}</strong>: #{show_assigned_to(issue)}<br /> " +
      "<strong>#{@cached_label_priority}</strong>: #{issue.priority.name}"
    end

    return tooltip
  end
  
  # Returns a string of css classes that apply to the given issue
  def css_issue_classes(issue)
    s = "issue status-#{issue.status.position} priority-#{issue.priority.position}"
    s << ' closed' if issue.closed?
    s << ' overdue' if issue.overdue?
    s << ' created-by-me' if User.current.logged? && issue.author_id == User.current.id
    s << ' assigned-to-me' if User.current.logged? && issue.assigned_to_id == User.current.id
    s
  end
  
  def sidebar_queries
    unless @sidebar_queries
      # User can see public queries and his own queries
      visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
      # Project specific queries and global queries
      visible << (@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id])
      @sidebar_queries = Query.find(:all, 
                                    :order => "name ASC",
                                    :conditions => visible.conditions)
    end
    @sidebar_queries
  end

  def show_detail(detail, no_html=false)
    case detail.property
    when 'attr'
      label = l(("field_" + detail.prop_key.to_s.gsub(/\_id$/, "")).to_sym)   
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value
      when 'project_id'
        p = Project.find_by_id(detail.value) and value = p.name if detail.value
        p = Project.find_by_id(detail.old_value) and old_value = p.name if detail.old_value
      when 'status_id'
        s = IssueStatus.find_by_id(detail.value) and value = s.name if detail.value
        s = IssueStatus.find_by_id(detail.old_value) and old_value = s.name if detail.old_value
      when 'tracker_id'
        t = Tracker.find_by_id(detail.value) and value = t.name if detail.value
        t = Tracker.find_by_id(detail.old_value) and old_value = t.name if detail.old_value
      when 'assigned_to_id'
        u = User.find_by_id(detail.value) and value = u.name if detail.value
        u = User.find_by_id(detail.old_value) and old_value = u.name if detail.old_value
      when 'priority_id'
        e = Enumeration.find_by_id(detail.value) and value = e.name if detail.value
        e = Enumeration.find_by_id(detail.old_value) and old_value = e.name if detail.old_value
      when 'category_id'
        c = IssueCategory.find_by_id(detail.value) and value = c.name if detail.value
        c = IssueCategory.find_by_id(detail.old_value) and old_value = c.name if detail.old_value
      when 'fixed_version_id'
        v = Version.find_by_id(detail.value) and value = v.name if detail.value
        v = Version.find_by_id(detail.old_value) and old_value = v.name if detail.old_value
      when 'estimated_hours'
        value = "%0.02f" % detail.value.to_f unless detail.value.blank?
        old_value = "%0.02f" % detail.old_value.to_f unless detail.old_value.blank?
      end
    when 'cf'
      custom_field = CustomField.find_by_id(detail.prop_key)
      if custom_field
        label = custom_field.name
        value = format_value(detail.value, custom_field.field_format) if detail.value
        old_value = format_value(detail.old_value, custom_field.field_format) if detail.old_value
      end
    when 'attachment'
      label = l(:label_attachment)
    end
    call_hook(:helper_issues_show_detail_after_setting, {:detail => detail, :label => label, :value => value, :old_value => old_value })

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value
    
    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      old_value = content_tag("strike", old_value) if detail.old_value and (!detail.value or detail.value.empty?)
      if detail.property == 'attachment' && !value.blank? && a = FileAttachment.find_by_id(detail.prop_key)
        # Link to the attachment if it has not been removed
        value = link_to_attachment(a)
      else
        value = content_tag("i", h(value)) if value
      end
    end
    
    if !detail.value.blank?
      case detail.property
      when 'attr', 'cf'
        if !detail.old_value.blank?
          label + " " + l(:text_journal_changed, old_value, value)
        else
          label + " " + l(:text_journal_set_to, value)
        end
      when 'attachment'
        "#{label} #{value} #{l(:label_added)}"
      end
    else
      case detail.property
      when 'attr', 'cf'
        label + " " + l(:text_journal_deleted) + " (#{old_value})"
      when 'attachment'
        "#{label} #{old_value} #{l(:label_deleted)}"
      end
    end
  end
  
  def issues_to_csv(issues, project = nil)
    ic = Iconv.new(l(:general_csv_encoding), 'UTF-8')    
    decimal_separator = l(:general_csv_decimal_separator)
    export = StringIO.new
    CSV::Writer.generate(export, l(:general_csv_separator)) do |csv|
      # csv header fields
      headers = [ "#",
                  l(:field_status), 
                  l(:field_project),
                  l(:field_tracker),
                  l(:field_priority),
                  l(:field_subject),
                  l(:field_assigned_to),
                  l(:field_category),
                  l(:field_fixed_version),
                  l(:field_author),
                  l(:field_start_date),
                  l(:field_due_date),
                  l(:field_done_ratio),
                  l(:field_estimated_hours),
                  l(:field_created_on),
                  l(:field_updated_on)
                  ]
      # Export project custom fields if project is given
      # otherwise export custom fields marked as "For all projects"
      custom_fields = project.nil? ? IssueCustomField.for_all : project.all_issue_custom_fields
      custom_fields.each {|f| headers << f.name}
      # Description in the last column
      headers << l(:field_description)
      csv << headers.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      # csv lines
      issues.each do |issue|
        fields = [issue.id,
                  issue.status.name, 
                  issue.project.name,
                  issue.tracker.name, 
                  issue.priority.name,
                  issue.subject,
                  issue.assigned_to,
                  issue.category,
                  issue.fixed_version,
                  issue.author.name,
                  format_date(issue.start_date),
                  format_date(issue.due_date),
                  issue.done_ratio,
                  issue.estimated_hours.to_s.gsub('.', decimal_separator),
                  format_time(issue.created_on),  
                  format_time(issue.updated_on)
                  ]
        custom_fields.each {|f| fields << show_value(issue.custom_value_for(f)) }
        fields << issue.description
        csv << fields.collect {|c| begin; ic.iconv(c.to_s); rescue; c.to_s; end }
      end
    end
    export.rewind
    export
  end

  def show_assigned_to(issue)
    return "-" if issue.assignments.nil?
    html = ""
    issue.assignments.each_with_index do |assignment,index|
      user = assignment.user     
      html += avatar(user, :size => "14") ? avatar(user, :size => "14") : ""
      html += link_to_user(user)
      html += (index==issue.assignments.size-1)? "":","
    end
    return html
  end

   def show_assigned_to_list(issue)
    return "-" if issue.assignments.nil?
    html =""
    issue.assignments.each_with_index do |assignment,index|
      user = assignment.user
      html += avatar(user, :size => "14") ? avatar(user, :size => "14") : ""
      html += link_to_user(user)
      html += (index==issue.assignments.size-1)? "":"<br/>"
    end
    return html
  end

  def tree_gantt_list(events)
    ret = ""   
    events.collect do |event| 
        if event.class ==  Issue
          ret = "<div style='height:20px;padding-left:#{event.level*20}px'>"
          
          ret += "#{link_to_issue event}<br/>"
          ret += "</div>"
          ret += "#{tree_gantt_list(event.children) if event.children.size>0}" 
        else
          ret = "<div style='height:20px;>"
          ret += "<span class='icon icon-package'>"
          ret += "Version :  "
          ret += "#{link_to_version event}"
          ret += "</span>"
          ret += "</div>"
        end
                    
           
    end
  end

  def top
    @@top
  end

  def tree_gantt(top,gantt,zoom, events, init = false)
    ret = ""
    if init
      @@top = top
    end
    events.collect do |i|
      if i.class == Issue and (i.is_issue? or i.is_stage?)
          i_start_date = (i.start_date >= gantt.date_from ? i.start_date : gantt.date_from )
          i_end_date = ((i.due_before and i.due_before <= gantt.date_to) ? i.due_before : gantt.date_to )
          
          
          i_done_date = i.start_date + ((i_end_date - i.start_date+1)*i.done_ratio/100).floor
          i_done_date = (i_done_date <= gantt.date_from ? gantt.date_from : i_done_date )
          i_done_date = (i_done_date >= gantt.date_to ? gantt.date_to : i_done_date )

          i_late_date = [i_end_date, Date.today].min if i_start_date < Date.today

          i_left = ((i_start_date - gantt.date_from)*zoom).floor
          i_width = ((i_end_date - i_start_date + 1)*zoom).floor - 2                  # total width of the issue (- 2 for left and right borders)
          d_width = ((i_done_date - i_start_date)*zoom).floor - 2                     # done width
          l_width = i_late_date ? ((i_late_date - i_start_date+1)*zoom).floor - 2 : 0 # delay width
	
          ret ="<div style='top:#{@@top}px;left:#{i_left}px;width:#{i_width}px;' class='task task_todo'>&nbsp;</div>"
          if l_width > 0
            ret += "<div style='top:#{@@top}px;left:#{i_left}px;width:#{l_width}px;' class='task task_late'>&nbsp;</div>"
          end
          if d_width > 0
            ret += "<div style='top:#{@@top}px;left:#{i_left}px;width:#{d_width}px;' class='task task_done'>&nbsp;</div>"
          end
          ret += "<div style='top:#{@@top+3}px;left:#{i_left + i_width + 5}px;' class='task'>"
          ret += "#{i.status.name}"
          ret += " #{(i.done_ratio).to_i}%"
          ret += "</div>"
          ret += "<div class='tooltip' style='position: absolute;top:#{@@top}px;left:#{i_left}px;width:#{i_width}px;height:12px;'>"
          ret += "<span class='tip'>"
          ret += "#{render_issue_tooltip i}"
          ret += "</span></div>"
        else
          if i.class == Issue and i.is_milestone?
            i_left = ((i.start_date - gantt.date_from)*zoom).floor
            ret = "<div style='top:#{@@top}px;left:#{i_left}px;width:15px;' class='task milestone'>&nbsp;</div>"
            ret += "<div style='top:#{@@top}px;left:#{i_left + 12}px;background:#fff;' class='task'>"
#            ret += "#{h(i.subject)}"
            ret += "</div>"
          else
            i_left = ((i.start_date - gantt.date_from)*zoom).floor
            ret = "<div style='top:#{@@top}px;left:#{i_left}px;width:15px;' class='task version'>&nbsp;</div>"
            ret += "<div style='top:#{@@top}px;left:#{i_left + 12}px;margin-left:5px;' class='task'>"
            ret += "<strong>#{h i}</strong>"
            ret += "</div>"
          end
        end
        @@top = @@top + 20        
        ret += "#{tree_gantt(@@top,gantt, zoom, i.children, false) if i.class==Issue and i.children.size>0}"
      end 
  end




end
