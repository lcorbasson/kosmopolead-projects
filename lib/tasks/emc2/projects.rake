# EMC2 Tasks
namespace :emc2 do
  
  # Create users from emc2_projects.csv file
  task :create_projects => :environment do
    # Chargement de la librairie FasterCSV
    require 'fastercsv'
    # Definition du file path
    projects_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_projects.csv"
    @@log_projects_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_log_projects.csv"
    @@log_projects_newusers_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_log_new_users.csv"

    # Verification de l existance du fichier
    unless File.exist?(projects_file)
      p "EMC2 Projects File not found"
      exit
    end
    
    # Definition de la communaute
    emc2_obj = Community.find_or_create_by_name('EMC2')

    # Ouverture du fichier a parser avec FasterCSV
    FasterCSV.foreach(projects_file) do |row|
      # Definition des champs contenu dans CSV

      # Attribut du projet
      prj_statut = row[0]
      designer_prenom = row[1]
      designer_nom = row[2]
      watcher_prenom = row[3]
      watcher_nom = row[4]
      prj_acronym = row[5]
      prj_name = row[6]
      prj_cost = row[7] # h

      # Tableau de financement
      aap = row[8]
      backer = row[9]
      
      # 2 types facultatif
      subvention = row[10]
      avance_remboursable = row[11]
      agreed_on = row[12]

      # Attribut custom du projet
      date_reception_pre_prj = row[13]
      experts = row[14]
      date_expertise = row[15]
      date_reception_prj = row[16]
      labelisation = row[17]
      labelisation_on = row[18]
      date_demarrage = row[19]
      date_fin = row[20]

      # Attribut du projet
      duree = row[21]
      auteur_entite = row[22]
      auteur_prenom = row[23]
      auteur_nom = row[24]

      # Creation de l objet projet avec les attributs generique
      prj_obj = create_project_generic_attributes(:status => prj_statut,
                                        :designer_prenom => designer_prenom,
                                        :designer_nom => designer_nom,
                                        :watcher_prenom => watcher_prenom,
                                        :watcher_nom => watcher_nom,
                                        :prj_acrynym => prj_acronym,
                                        :prj_name => prj_name,
                                        :prj_cost => prj_cost,
                                        :duree => duree,
                                        :auteur_entite => auteur_entite,
                                        :auteur_prenom => auteur_prenom,
                                        :auteur_nom => auteur_nom,
                                        :emc2_obj => emc2_obj
      )


    end
  end

  # Fonctions

  def create_project_generic_attributes(*args)
    # Instanciation de variables
    time_obj = nil
    
    # Recuperation des options
    options = args.extract_options!

    # Verification de la bonne presence du statut
    return nil if retrieve_status_obj(options[:status]).nil?

    # Options
    options.each {|m| p "#{m}"}
    p "#{Project.next_identifier}"

    # Recuperation du TimeUnits
    time_obj = TimeUnit.find_by_label("months")

    # Recuperation du monteur
    designer_obj = retrieve_user_obj(options[:designer_nom], options[:designer_prenom])
    
    # Recuperation de l utilisateur qui suit le projet
    watcher_obj = retrieve_user_obj(options[:watcher_nom], options[:watcher_prenom])

    # Recuperation de l auteur
    auteur_obj = retrieve_user_obj(options[:auteur_nom], options[:auteur_prenom])

    # Creation du projet avec les attributs generique
    prj_obj = Project.new(
      :acronym => options[:prj_acrynym],
      :name => options[:prj_name],
      :project_cost => options[:project_cost],
      :estimated_time => options[:duree].to_i,
      :time_units_id => time_obj.id || nil,
      :community_id => options[:emc2_obj].id,
      :identifier => Project.next_identifier
    )

    # Application du watcher si il est present sur le projet
    prj_obj.watcher_id = watcher_obj.id unless watcher_obj.nil?
    prj_obj.author_id = auteur_obj.id unless auteur_obj.nil?
    prj_obj.designer_id = designer_obj.id unless designer_obj.nil?

    # Persistance du projet en base
    prj_obj.save

    p "PROJET #{prj_obj}"

    # Creation du partner si il est renseigne
    unless options[:auteur_entite].nil? || options[:auteur_entite].blank?
      partner_obj = Partner.find_or_create_by_name(options[:auteur_entite])
      partner_obj.update_attribute(:community_id,options[:emc2_obj].id)
    else
      partner_obj = nil
    end

    # Si l auteur ainsi que le parter sont presents
    if auteur_obj && partner_obj
      # Association Partnership et Auteur
      Partnership.create(:user_id => auteur_obj.id, :partner_id => partner_obj.id)
    end
    
    prj_obj
  end

  def retrieve_user_obj(lastname, firstname)
    # Recherche de l utilisateur
    user_obj = User.find(:first, :conditions => {:lastname => lastname, :firstname => firstname})

    # Si l utilisateur n a pas ete trouve
    if user_obj.nil?
      # Creation de l utilisateur
      user_obj = create_single_user(lastname, firstname, nil, @@log_projects_newusers_file)
    end

    user_obj
  end

  def retrieve_status_obj(status)
    # Recherche du statut du projet
    ProjectStatus.find_by_status_label(status)
  end

  def remove_special_accent(string)
    '' if !string
    
    string = string.downcase
    string = string.gsub(/[éèëêÈÉ]/, 'e')
    string = string.gsub(/[âäà]/, 'a')
    string = string.gsub(/[öô]/, 'o')
    string = string.gsub(/[ûüù]/, 'u')
    string = string.gsub(/[ïî]/, 'i')
    string = string.gsub(/[çÇ]/, 'c')
    string = string.gsub(/[\s']/, '')
    string
  end

end
