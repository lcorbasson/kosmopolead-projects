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

module ProjectsHelper
  def link_to_version(version, options = {})
    return '' unless version && version.is_a?(Version)
    link_to h(version.name), { :controller => 'versions', :action => 'show', :id => version }, options
  end

 def project_tabs
    tabs = [{:name => 'gantt', :partial => 'projects/show/gantt', :label => :label_gantt},
            {:name => 'funding', :partial => 'projects/show/funding', :label => :label_funding},
            {:name => 'synthesis', :partial => 'projects/show/synthesis', :label => :label_synthese},            
            {:name => 'files', :partial => 'projects/show/files', :label => :label_file_plural},
            {:name => 'gallery', :partial => 'projects/show/gallery', :label => :label_gallery_photos}
            ]
  end

 def project_tabs_members
    tabs = [{:name => 'members', :partial => 'projects/show/members', :label => :label_members},
            {:name => 'partners', :partial => 'projects/show/partners', :label => :label_partners}
            ]
  end
  
  def project_status_options_for_select()
    ProjectStatus.all.collect{|s| [s.status_label, s.id]}
  end



   def project_settings_tabs
    tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
           
            {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
           
            {:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural},
            {:name => 'categories', :action => :manage_categories, :partial => 'projects/settings/issue_categories', :label => :label_issue_category_plural},
            {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki}
            
            ]
#    tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
  end

  def tags_json
    rows = []
    @tags.each  do  |t|
      rows << {:caption => t.name, :value => t.name}
    end
    return rows.to_json
  end


 def time_units
   TimeUnit.all.each { |t|  [t.label, t.id] }
 end

 def funding_lines_to_json
      #Construction du tableau à renvoyer à jqgrid
      hash_json={}
      rows=[]
       if @project.funding_lines.size>0
        @project.funding_lines.each do |line|
          rows << {:id=>line.id,:cell=>[line.aap,line.financeur,line.correspondant_financeur,line.montant_demande,line.funding_type,line.date_accord,line.montant_accorde,line.date_liberation,line.montant_libere,"#{link_to_remote(image_tag('/images/delete.png'),{ :url=>project_funding_line_path(@project,line),:method=>:delete,:confirm=>"Etes-vous certain de vouloir supprimer cette ligne ?"})} #{link_to_remote(image_tag('/images/edit.png'),{ :url=>edit_project_funding_line_path(@project,line),:method=>:get})}"]}
        end
      end
     hash_json = {"page"=>@page,"total"=>@total_pages,"records"=>@records,"rows"=>rows}
     
     return hash_json.to_json
   end

    def list_sectors(language)
      ActivitySectorTranslation.find(:all, :conditions => {:local => language.to_s})
    end

    def my_sector(language, id)
      ActivitySectorTranslation.find(:all, :conditions => {:local => language.to_s, :activity_sector_id => id})
    end

    def custom_field_sort(custom_fields, bool = false)
      boolean = []
      other = []

      custom_fields.each do |custom|
        custom.custom_field.field_format.eql?('bool') ? boolean << custom : other << custom
      end
      bool ? boolean : other
    end

    def partner_project(project)
      partner_name = ""
      partnerships = project.author.partnerships
      project_partners = project.project_partners
      partnerships.each do |partnership|
        partner = Partner.find(partnership.partner_id)
        if partner_project = ProjectPartner.find(:first,:conditions=>["partner_id = ? and project_id = ?",partner.id, project.id])
          partner_name=="" ? partner_name += partner.name : partner_name += ", "+partner.name
        end
      end
      return partner_name
    end
end