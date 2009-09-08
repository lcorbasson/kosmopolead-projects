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

require "digest/md5"

class FileAttachment < ActiveRecord::Base  

  # -- paperclip

  has_attached_file :file,
    :url => "/picts/:attachment/:id/:style/:filename",
    :path => ":rails_root/public:url"

  # -- validation


  validates_attachment_presence :file
    
  

  # -- relations
  
  belongs_to :container, :polymorphic => true
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"

  def container
    case container_type
      when "project"
        container = Project.find(self.container_id)
      when "issue"
        container = Issue.find(self.container_id)
      when "version"
        container = Version.find(self.container_id)
    end
  end


  def increment_download
    increment!(:downloads)
  end


  
end
