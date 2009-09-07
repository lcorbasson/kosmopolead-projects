ActionController::Routing::Routes.draw do |map|
  map.resources :activity_sectors, :has_many => :activity_sector_translations

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Allow Redmine plugins to map routes and potentially override them
  Rails.plugins.each do |plugin|
    map.from_plugin plugin.name.to_sym
  end

  map.home '', :controller => 'my',:action=>"page"
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  map.connect 'queries',:controller=>'queries'



  map.resources :projects,:collection=>{:add_version=>:get,:show_funding=>:get,:add=>:get,:settings=>:get} do |project|
      project.resources :members
      project.resources :issues,:member=>{:move=>:get},:collection=>{:move=>:get,:calendar=>:get,:gantt=>:get,:type_event=>:get} do |issue|
        issue.resources :file_attachments
        issue.resources :issue_relations
      end
      project.resources :gallery do |gallery|
        gallery.resources :photos
      end
      project.resources :file_attachments
      project.resources :wikis
      project.resources :project_partners do |project_partner|
        project_partner.resources :partner
      end
      project.resources :project_relations do |project_relation|
        project_relation.resources :project_relation_type
      end
      project.resources :news
      project.resources :boards
      project.resources :funding_lines
      project.resources :activity_sector
  end

 
  
  map.connect 'wiki/:id/:page/:action', :controller => 'wiki', :page => nil
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help'


 
  map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/
  map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'


  map.with_options :controller => 'repositories' do |omap|
    omap.repositories_show 'repositories/browse/:id/*path', :action => 'browse'
    omap.repositories_changes 'repositories/changes/:id/*path', :action => 'changes'
    omap.repositories_diff 'repositories/diff/:id/*path', :action => 'diff'
    omap.repositories_entry 'repositories/entry/:id/*path', :action => 'entry'
    omap.repositories_entry 'repositories/annotate/:id/*path', :action => 'annotate'
    omap.repositories_revision 'repositories/revision/:id/:rev', :action => 'revision'
  end



  map.connect 'file_attachments', :controller => 'file_attachments'
  
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

 
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
