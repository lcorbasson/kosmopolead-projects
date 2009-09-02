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

  map.home '', :controller => 'welcome'
  map.signin 'login', :controller => 'account', :action => 'login'
  map.signout 'logout', :controller => 'account', :action => 'logout'
  
  map.connect 'wiki/:id/:page/:action', :controller => 'wiki', :page => nil
  map.connect 'roles/workflow/:id/:role_id/:tracker_id', :controller => 'roles', :action => 'workflow'
  map.connect 'help/:ctrl/:page', :controller => 'help'
  #map.connect ':controller/:action/:id/:sort_key/:sort_order'

  map.connect 'projects/:action',:controller=>'projects'
  map.connect 'projects/:project_id/:action',:controller=>'projects'
  
  map.connect 'projects/:project_id/wikis/:action/:id',:controller=>'wikis'
  map.connect 'projects/:project_id/project_partners/:action/:id',:controller=>'project_partners'
  map.connect 'partners/:action',:controller=>'partners'
  map.connect 'projects/:project_id/:action', :controller => 'projects'
  map.connect 'project_relation_types', :controller => 'project_relation_types'
  map.connect 'projects/:project_id/relations/:action/:id', :controller => 'project_relations'
  map.connect 'projects/:project_id/gallery/:gallery_id/photos/:action', :controller => 'photos'
  map.connect 'issues/:issue_id/relations/:action/:id', :controller => 'issue_relations'
  map.connect 'projects/:project_id/issues/:action', :controller => 'issues'
  map.resources :projects do |project|
      project.resources :issues
  end

  map.connect 'projects/:project_id/news/:action', :controller => 'news'
  map.connect 'projects/:project_id/documents/:action', :controller => 'documents'
  map.connect 'projects/:project_id/boards/:action/:id', :controller => 'boards'
  map.connect 'projects/:project_id/funding_lines/:action/:id', :controller => 'funding_lines'
  map.connect 'projects/:action/:project_id', :controller => 'projects'
  map.connect 'projects/:project_id/file_attachments/:action/:id', :controller => 'file_attachments'
  map.connect 'projects/:project_id/timelog/:action/:id', :controller => 'timelog', :project_id => /.+/
  map.connect 'boards/:board_id/topics/:action/:id', :controller => 'messages'
  map.connect 'projects/:project_id/issues/:issue_id/file_attachments/:action/:id', :controller => 'file_attachments'

  map.with_options :controller => 'repositories' do |omap|
    omap.repositories_show 'repositories/browse/:id/*path', :action => 'browse'
    omap.repositories_changes 'repositories/changes/:id/*path', :action => 'changes'
    omap.repositories_diff 'repositories/diff/:id/*path', :action => 'diff'
    omap.repositories_entry 'repositories/entry/:id/*path', :action => 'entry'
    omap.repositories_entry 'repositories/annotate/:id/*path', :action => 'annotate'
    omap.repositories_revision 'repositories/revision/:id/:rev', :action => 'revision'
  end

  map.connect 'activity_sectors/:action/:id', :controller => 'activity_sectors'


  map.connect 'file_attachments/:id', :controller => 'file_attachments', :action => 'show', :id => /\d+/
  map.connect 'file_attachments/:id/:filename', :controller => 'file_attachments', :action => 'show', :id => /\d+/, :filename => /.*/
  map.connect 'file_attachments/download/:id/:filename', :controller => 'file_attachments', :action => 'download', :id => /\d+/, :filename => /.*/
   
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

 
  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
