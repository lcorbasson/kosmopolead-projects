# EMC2 Tasks
namespace :emc2 do

  # Bootstrap users partners
  task :bootstrap_inactive => :environment do
    # Inactive Users Purge
    puts "   Purge des Users EMC2 ..."
    Rake::Task['emc2:delete_inactive_users'].invoke
    
    # Inactive Partners Purge
    puts "   Purge des Partners EMC2 ..."
    Rake::Task['emc2:delete_inactive_partners'].invoke
  end
  
  # Delete inactive users EMC2
  task :delete_inactive_users => :environment do
    # Definition de la communaute
    emc2 = Community.find_or_create_by_name('EMC2')

    members = Member.all.collect(&:user_id)
    authors = emc2.projects.collect(&:author_id)
    designers = emc2.projects.collect(&:designer_id)
    watchers = emc2.projects.collect(&:watcher_id)

    ids = (members + authors + designers + watchers).flatten.compact

    # Suppression des utilisateurs inactive de la communaute
    emc2.users.all(:conditions => ["users.id not in (?)", ids + [1]]).each(&:destroy)
  end

  # Delete inactive partners EMC2
  task :delete_inactive_partners => :environment do
    # Definition de la communaute
    emc2 = Community.find_or_create_by_name('EMC2')

    partners = emc2.partners.select{ |p| ProjectPartner.find_by_partner_id(p.id)}.collect(&:id).flatten.compact

    # Suppression des partners inactive pour la communaute EMC2
    emc2.partners.all(:conditions => ["partners.id not in (?)", partners]).select{ |u| u.destroy}
  end

end
