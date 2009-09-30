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
      auteur_prenom = row[23] || ''
      auteur_nom = row[24] || ''

      # Creation de l objet projet avec les attributs generique
      prj_obj = create_project_generic_attributes(:status => prj_statut,
                                        :designer_prenom => designer_prenom,
                                        :designer_nom => designer_nom,
                                        :watcher_prenom => watcher_prenom,
                                        :watcher_nom => watcher_nom,
                                        :prj_acronym => prj_acronym,
                                        :prj_name => prj_name,
                                        :prj_cost => prj_cost,
                                        :duree => duree,
                                        :auteur_entite => auteur_entite,
                                        :auteur_prenom => auteur_prenom,
                                        :auteur_nom => auteur_nom,
                                        :emc2_obj => emc2_obj
      )

      unless prj_obj.nil?
        # Creation des custom_values
        custom_values = [ date_reception_pre_prj,
                          experts,
                          date_expertise,
                          date_reception_prj,
                          labelisation,
                          labelisation_on,
                          date_demarrage,
                          date_fin
        ]
        # Fonction de creations des custom_values
        create_custom_values_for_project(emc2_obj, prj_obj,custom_values)

        # Creation du tableau de financement
        create_funding_lines_for_project( :aap => aap,
                                          :backer => backer,
                                          :subvention => subvention,
                                          :avance_remboursable => avance_remboursable,
                                          :agreed_on => agreed_on,
                                          :prj_obj =>  prj_obj
                                        )
      end

    end
  end

  # Fonctions

  def create_funding_lines_for_project(*args)
    # Recuperation des parametres
    options = args.extract_options!
    
    # Creation d une funding_line specifique a un type
    FundingLine.create( :aap => options[:aap],
                        :backer => options[:backer],
                        :agreed_on => options[:agreed_on],
                        :project_id => options[:prj_obj].id,
                        :funding_type => 'Subvention',
                        :agreed_amount => options[:subvention]
                      ) unless options[:subvention].nil? || options[:subvention].blank?

    FundingLine.create( :aap => options[:aap],
                        :backer => options[:backer],
                        :agreed_on => options[:agreed_on],
                        :project_id => options[:prj_obj].id,
                        :funding_type => 'Avance Remboursable',
                        :agreed_amount => options[:avance_remboursable]
                      ) unless options[:avance_remboursable].nil? || options[:avance_remboursable].blank?
    
  end

  def create_custom_values_for_project(emc2_obj, project_obj, custom_values)
    # Custom_fields Objects
    custom_date_reception_pre_prj_obj = CustomField.find_by_name('Date réception Pré-projet', :conditions => {:community_id => emc2_obj.id})
    custom_experts_obj = CustomField.find_by_name('Experts', :conditions => {:community_id => emc2_obj.id})
    custom_date_expertise_obj = CustomField.find_by_name('Date Expertise', :conditions => {:community_id => emc2_obj.id})
    custom_date_reception_prj_obj = CustomField.find_by_name('Date réception Projet', :conditions => {:community_id => emc2_obj.id})
    custom_labelisation_obj = CustomField.find_by_name('Labellisation', :conditions => {:community_id => emc2_obj.id})
    custom_date_labelisation_obj = CustomField.find_by_name('Date Labellisation', :conditions => {:community_id => emc2_obj.id})
    custom_date_demarrage_obj = CustomField.find_by_name('Date Démarrage', :conditions => {:community_id => emc2_obj.id})
    custom_date_fin_obj = CustomField.find_by_name('Date de Fin', :conditions => {:community_id => emc2_obj.id})

    custom_fields = [custom_date_reception_pre_prj_obj,
                    custom_experts_obj,
                    custom_date_expertise_obj,
                    custom_date_reception_prj_obj,
                    custom_labelisation_obj,
                    custom_date_labelisation_obj,
                    custom_date_demarrage_obj,
                    custom_date_fin_obj
    ]

    custom_fields.each_with_index do |fields, index|
      p "#{fields} | #{index} | #{YAML.dump("#{custom_values[index]}")}"

      customvalue_obj = CustomValue.find(:first, :conditions => {:customized_type => 'Project', :customized_id => project_obj.id,:custom_field_id => fields.id})
      
      # Test si le custom_fields est de type date
      unless fields.field_format.eql?('date')
        customvalue_obj.update_attribute(:value,[custom_values[index]])
      else
        customvalue_obj.update_attribute(:value,custom_values[index])
      end

    end

  end

  def create_project_generic_attributes(*args)
    # Instanciation de variables
    time_obj = nil
    
    # Recuperation des options
    options = args.extract_options!

    # Verification de la bonne presence du statut
    status_obj = retrieve_status_obj(options[:emc2_obj], options[:status])
    return nil if status_obj.nil?

    # Options
    options.each {|m| p "#{m}"}

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
      :status_id => status_obj.id,
      :acronym => options[:prj_acronym],
      :name => options[:prj_name].blank? ? options[:prj_acronym] :  options[:prj_name],
      :project_cost => options[:prj_cost].to_i,
      :estimated_time => options[:duree].to_i,
      :time_units_id => time_obj.id || nil,
      :community_id => options[:emc2_obj].id,
      :identifier => Project.next_identifier,
      :archived => false
    )

    # Application du watcher si il est present sur le projet
    prj_obj.watcher_id = watcher_obj.id unless watcher_obj.nil?
    prj_obj.author_id = auteur_obj.id unless auteur_obj.nil?
    prj_obj.designer_id = designer_obj.id unless designer_obj.nil?

    # Persistance du projet en base
    prj_obj.save!

    # Creation du partner si il est renseigne
    unless options[:auteur_entite].nil? || options[:auteur_entite].blank?
      partner_obj = Partner.find_or_create_by_name(options[:auteur_entite])
      partner_obj.update_attribute(:community_id,options[:emc2_obj].id)
      ProjectPartner.create(:project_id => prj_obj.id, :partner_id => partner_obj.id)
    else
      partner_obj = nil
    end

    # Si l auteur ainsi que le parter sont presents
    if auteur_obj && partner_obj
      # Verification que l user n est pas dans le partner
      if Partnership.find(:first, :conditions => {:user_id => auteur_obj, :partner_id => partner_obj}).nil?
        # Association Partnership et Auteur
        Partnership.create(:user_id => auteur_obj.id, :partner_id => partner_obj.id)
      end
    end

    # Association auteur en tant que membre du projet
    if auteur_obj
      prj_obj.members << Member.new(:user_id => auteur_obj.id, :role_id => Role.find_by_name('Membre équipe projet').id)
    end
    
    return prj_obj
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

  def retrieve_status_obj(emc2_obj, status)
    # Recherche du statut du projet
    ProjectStatus.find(:first, :conditions => {:community_id => emc2_obj.id, :status_label => status})
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
