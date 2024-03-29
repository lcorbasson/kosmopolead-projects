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

class CustomValue < ActiveRecord::Base
  belongs_to :custom_field
  belongs_to :customized, :polymorphic => true
  serialize :value
 

  def after_initialize
    if custom_field && new_record? && (customized_type.blank? || (customized && customized.new_record?))
      self.value ||= custom_field.default_value
    end
  end
  
  # Returns true if the boolean custom value is true
  def true?
    self.value == '1'
  end

 
  
protected
  def validate
    if value.blank?
      errors.add(:value, :activerecord_error_blank) if custom_field.is_required? and value.blank?    
    else
      errors.add(:value, :activerecord_error_invalid) unless custom_field.regexp.blank? or value =~ Regexp.new(custom_field.regexp)
      errors.add(:value, :activerecord_error_too_short) if custom_field.min_length > 0 and value.length < custom_field.min_length
      errors.add(:value, :activerecord_error_too_long) if custom_field.max_length > 0 and value.length > custom_field.max_length
    
      # Format specific validations
      case custom_field.field_format
      when 'int'
        errors.add(:value, :activerecord_error_not_a_number) unless value =~ /^[+-]?\d+$/	
      when 'float'
        begin; Kernel.Float(value); rescue; errors.add(:value, :activerecord_error_invalid) end
      when 'date'
#       errors.add(:value, :activerecord_error_not_a_date) unless value =~ /^\d{2}\/\d{2}\/\d{4}$/
      when 'list'
        errors.add(:value, :activerecord_error_inclusion) unless custom_field.possible_values.include?(value)
      end
    end
  end


#  def save
#     custom_field = CustomField.find(self.custom_field_id)
#    if custom_field.field_format.eql?("date")
#      self.value = YAML.load("--- 2009-10-30")
#    end
#    super.save
#  end

end
