# Processing Capistrano Tasks for kosmopolead-projects
# 24/08/09
###########################################################

# Passenger Namespace
# Used to restart Passenger application
namespace :passenger do
	desc "Restart Application"
	task :restart, :roles => :app do
		run "touch #{current_path}/tmp/restart.txt"
	end
end

# Deploy Namespace
# Used to create symlink and restart passenger
namespace :deploy do
	desc "Restart the Passenger system."
	task :restart, :roles => :app do
		# Create symlinks
		###############################################################
		## Symlink database
		run "ln -s #{shared_path}/config/database.yml #{current_path}/config/database.yml"

		## Symlink Extensions and Plugins (désactivé pour redmine)
#		run "rm -rf #{current_path}/vendor"
#		run "ln -s #{shared_path}/vendor #{current_path}/vendor"

		## Symlink FileAttachments 
		run "rm -rf #{current_path}/public/picts"
		run "ln -s #{shared_path}/public/picts #{current_path}/public/picts"
		
                ## Symlink Logs
		run "rm -rf #{current_path}/log"
		run "ln -s #{shared_path}/log #{current_path}/"
		###############################################################
		
		# DB Migrate
		run "cd #{current_path}; rake db:migrate RAILS_ENV=#{rails_env}"
		
		# Call Passenger restart task
		passenger.restart
		
		# Cleanup
		cleanup
	end
end
