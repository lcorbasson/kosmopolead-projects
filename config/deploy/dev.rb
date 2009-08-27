#	General Capistrano Settings
############################################################
default_run_options[:pty] = true
set :use_sudo, true
set :keep_releases, 20
set :runner, "deployer"
set :spinner, false

#	Application Settings
###########################################################
# ex : kosmopolead-cms
set :application_fullname, "kosmopolead-projects"
# ex : Application short name is the directory name : cms (Located in /var/www/products/prod/cms)
set :application_shortname, "projects"
# ex : dev, beta or prod deploy
set :application_version,"dev"
# Passenger Rails env
set :rails_env, "development"

#	Repository Settings
#########################################################
# Source repository
set :repository,  "git@github.com:uneek/kosmopolead-projects.git"
# Repository Type
set :scm, "git"

#	SSH Settings
#############################################################
# ex : prod-ssh.uneek.eu
set :ssh_server_target, "#{application_version}-ssh.uneek.eu"
set :user, "deployer"
set :domain, "#{ssh_server_target}"
set :port, "24000"

#	Deploy Settings
###########################################################
# Define Target domaine for each roles
role :web, "#{ssh_server_target}"
role :app, "#{ssh_server_target}"
role :db,  "#{ssh_server_target}", :primary => true
# ex : /var/www/products/prod/cms
set :deploy_to, "/var/www/products/#{application_version}/#{application_shortname}"
# ex : /var/www/products/prod/cms/shared
set :shared_path, "/var/www/products/#{application_version}/#{application_shortname}/shared"

#	Load Configuration File
#########################################################
eval IO.read(File.join('config', 'deploy', 'config.rb'))
