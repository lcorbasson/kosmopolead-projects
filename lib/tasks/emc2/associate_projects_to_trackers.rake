# EMC2 Tasks
namespace :emc2 do
  
  # Associate projects_to_trackers
  task :associate_trackers_to_projects => :environment do
   # Récupération de la communauté
   emc2_obj = Community.find_by_name('EMC2')

   # Association des trackers aux projets
   emc2_obj.projects.each do |project|
     Tracker.all.each do |tracker|
       project.trackers<<tracker
     end
   end

  end

end
