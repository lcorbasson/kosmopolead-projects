# EMC2 Tasks
namespace :emc2 do

  # Bootstrap CRM into projects
  task :bootstrap_crm_into_projects => :environment do
    # Import des accounts CRM dans Projects
    puts "   Import des accounts CRM dans PROJECTS ..."
    Rake::Task['emc2:uptodate_partners'].invoke

    # Import des contacts CRM dans PROJECTS
    puts "   Import des contacts CRM dans PROJECTS..."
    Rake::Task['emc2:uptodate_users'].invoke
  end

  # Bootstrap CRM into projects
  task :bootstrap_crm_into_projects_with_purge => :environment do
    # Purge des associations Accounts // Contacts
    puts "   Purge des associations Accounts / Contacts ..."
    Partnership.all.each(&:destroy)

    # Import des accounts CRM dans Projects
    puts "   Import des accounts CRM dans PROJECTS ..."
    Rake::Task['emc2:uptodate_partners'].invoke

    # Import des contacts CRM dans PROJECTS
    puts "   Import des contacts CRM dans PROJECTS..."
    Rake::Task['emc2:uptodate_users'].invoke
  end
  
  # Create partners from csv file
  task :uptodate_partners => :environment do
    require 'fastercsv'

    # Definition du file path
    crm_account = "#{RAILS_ROOT}/lib/tasks/emc2/uptodate/accounts-151209.csv"

    # Recuperation ou creation de la communaute EMC2 sur Kosmopolead-CRM
    emc2 = Community.find_or_create_by_name("EMC2")

    FasterCSV.foreach(crm_account) do |row|
      # Instanciation de variables
      name = row[0]

      # Recuperation ou creation de l entite
      partner = Partner.find_by_name(name)

      # Si l entite n a pas ete trouve
      unless partner
        partner = Partner.create!( :name => name)
        partner.update_attribute(:community_id,emc2.id)
        partner.save!
      end
    end
  end

  task :uptodate_users => :environment do
    require 'fastercsv'

    # Definition du file path
    crm_users = "#{RAILS_ROOT}/lib/tasks/emc2/uptodate/account-contacts-151209.csv"

    # Recuperation ou creation de la communaute EMC2 sur Kosmopolead-CRM
    emc2 = Community.find_or_create_by_name("EMC2")

    FasterCSV.foreach(crm_users, :col_sep => ';') do |row|
      prenom = row[0]
      nom = row[1]
      email = row[2]
      account_name = row[3]

      p "#{prenom} | #{nom}"

      user = new_create_single_user(nom, prenom, email, emc2, file = "#{RAILS_ROOT}/lib/tasks/emc2/uptodate/new_users_password.csv")

      # Recuperation ou creation de l entite
      partner = Partner.find_by_name(account_name)

      # Si le partnership n a pas ete cree
      unless partner.partnerships.find_by_partner_id(user)
        # Creation du partnership
        Partnership.create(:user_id => user.id, :partner_id => partner.id)
      end
    end
  end

  ######################
  # FONCTIONS UPTODATE #
  ######################

  # Creation d un utilisateur
  def new_create_single_user(lastname, firstname, mail, community, file = @@passwd_users_file)
    result = nil

    # Verification de la presence des champs
    unless (lastname.blank? && firstname.blank?)
      # Verification de la presence de l user
      user_obj = User.find(:first, :conditions => {:lastname => lastname, :firstname => firstname})
      result = user_obj

      # Si l user est pas trouve
      if user_obj.nil?
        if mail
          mail = mail.gsub(/\s/, '')
        else
          mail = nil
        end

        # Creation de l user
        user_obj = User.new(:lastname => lastname, :firstname => firstname, :mail => mail, :status => 1, :type => 'User')

        # Concatenation du nom et du prenom
        login = concate_lastname_firstname(lastname, firstname)

        password = generate_password

        user_obj.login = login
        user_obj.password = password
        user_obj.save!
        result = user_obj

        # Ecriture des mots de passe
        FasterCSV.open(file, "a") do |csv|
          csv << [user_obj.login, password]
        end

        CommunityMembership.create(:user_id => user_obj.id, :community_id => community.id) unless user_obj.nil?
      end
    end
    result
  end
end
