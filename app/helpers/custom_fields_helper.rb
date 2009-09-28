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

module CustomFieldsHelper

  def custom_fields_tabs
    tabs = [{:name => 'IssueCustomField', :label => :label_issue_plural},
            {:name => 'TimeEntryCustomField', :label => :label_spent_time},
            {:name => 'ProjectCustomField', :label => :label_project_plural}
            #{:name => 'UserCustomField', :label => :label_user_plural}
            ]
  end
  
  # Return custom field html tag corresponding to its format
  def custom_field_tag(name, custom_value, read_only = false)
    custom_field = custom_value.custom_field
    field_name = "#{name}[custom_field_values][#{custom_field.id}]"
    field_id = "#{name}_custom_field_values_#{custom_field.id}"
    
    case custom_field.field_format
    when "date"
      if read_only
        custom_value.value.is_a?(Integer)|| custom_value.value.is_a?(FalseClass) ? "" : "<p>#{custom_value.value}</p>"
      else
        text_field_tag(field_name, custom_value.value.is_a?(Integer)|| custom_value.value.is_a?(FalseClass) ? "" : custom_value.value, :id => field_id, :size => 10, :readonly => read_only,:class=>"ui-datepicker") +
        initialize_datepicker()
      end

    when "text"
      if read_only
        custom_value.value.is_a?(Integer)|| custom_value.value.is_a?(FalseClass) ? "" : "<p>#{custom_value.value}</p>"
      else
        text_area_tag(field_name, custom_value.value.is_a?(Integer)|| custom_value.value.is_a?(FalseClass) ? "" : custom_value.value, :id => field_id, :rows => 3, :style => 'width:90%')
      end
    when "bool"
      check_box_tag(field_name, '1', custom_value.value.eql?(1) ? true : false , :id => field_id, :readonly => read_only, :disabled => read_only) + hidden_field_tag(field_name, '0')
    when "list"
      blank_option = custom_field.is_required? ?
                       (custom_field.default_value.blank? ? "<option value=\"\">--- #{l(:actionview_instancetag_blank_option)} ---</option>" : '') : 
                       '<option></option>'
      if read_only
        custom_value.value.is_a?(FalseClass)||custom_value.value.is_a?(Fixnum) ? "" : "<p>#{custom_value.value.collect.join(', ')}</p>"
      else
        select_tag(field_name, blank_option + options_for_select(custom_field.possible_values, custom_value.value), :id => field_id)
      end
    when 'multi_list'
      if read_only
        custom_value.value.is_a?(FalseClass)||custom_value.value.is_a?(Fixnum) ? "" : "<p>#{custom_value.value.collect.join(', ')}</p>"
      else
        select_tag(field_name+'[]', options_for_select(custom_field.possible_values, custom_value.value), :id => field_id, :multiple => true)
      end
    else
      if read_only
        custom_value.value.is_a?(FalseClass) ? "" : "<p>#{custom_value.value}</p>"
      else
        text_field_tag(field_name, custom_value.value, :id => field_id)
      end
    end
  end
  
  # Return custom field label tag
  def custom_field_label_tag(name, custom_value, read_only = false)
    content_tag "label", custom_value.custom_field.name +
	(custom_value.custom_field.is_required? ? " <span class=\"required\">*</span>" : ""),
	:for => "#{name}_custom_field_values_#{custom_value.custom_field.id}",
	:class => (custom_value.errors.empty? ? nil : "error" ),
  :readonly => read_only
  end
  
  # Return custom field tag with its label tag
  def custom_field_tag_with_label(name, custom_value, read_only = false)
    custom_field_label_tag(name, custom_value, read_only) + custom_field_tag(name, custom_value, read_only)
  end

  # Return a string used to display a custom value
  def show_value(custom_value)
    return "" unless custom_value
    format_value(custom_value.value, custom_value.custom_field.field_format)
  end
  
  # Return a string used to display a custom value
  def format_value(value, field_format)
    return "" unless value && !value.nil?
    field_format
    case field_format
    when "date"
      value.is_a?(FalseClass)||value.is_a?(Fixnum) ? "" : begin; format_date(value.to_date); rescue; value end
    when "bool"
      l_YesNo(value == "1")
    when 'multi_list'
        value.is_a?(FalseClass)||value.is_a?(Fixnum) ? "" : "#{value.collect.join(', ')}"
    when 'list'
        value.is_a?(FalseClass)||value.is_a?(Fixnum) ? "" : value
    when 'text'
        value.is_a?(FalseClass)||value.is_a?(Fixnum) ? "" : value
    else
      value
    end
  end

  # Return an array of custom field formats which can be used in select_tag
  def custom_field_formats_for_select
    CustomField::FIELD_FORMATS.sort {|a,b| a[1][:order]<=>b[1][:order]}.collect { |k| [ l(k[1][:name]), k[0] ] }
  end
end
