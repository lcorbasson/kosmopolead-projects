# EMC2 Tasks
namespace :emc2 do
  
  # Create users from emc2_users.csv file
  task :create_users => :environment do
    # Chargement de la librairie FasterCSV
    require 'fastercsv'
    # Definition du file path
    users_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_users.csv"
    @@passwd_users_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_password_users.csv"

    # Verification de l existance du fichier
    unless File.exist?(users_file)
      p "EMC2 Users File not found"
      exit
    end

    # Remise a plat du fichier password
    if File.exist?(@@passwd_users_file)
      File.delete(@@passwd_users_file)
    end
    
    # Definition de la communaute
    emc2_obj = Community.find_or_create_by_name('EMC2')

    # Ouverture du fichier a parser avec FasterCSV
    FasterCSV.foreach(users_file) do |row|
      # Definition des champs contenu dans CSV
      partner = row[0] || ''
      firstname = row[1] || ''
      lastname = row[2] || ''
      mail = row[3]

      # Presence de la cellule partner
      unless partner.blank?
        # Verification de sa presence dans la communaute et creation
        partner_obj = Partner.find_or_create_by_name(row[0])
        partner_obj.update_attribute(:community_id,emc2_obj.id)

        # Creation de l utilisateur
        user_obj = create_single_user(lastname, firstname, mail)

        Partnership.create(:user_id => user_obj.id, :partner_id => partner_obj.id) unless user_obj.nil?
      else
        user_obj = create_single_user(lastname, firstname, mail)
      end
      CommunityMembership.create(:user_id => user_obj.id, :community_id => emc2_obj.id) unless user_obj.nil?
    end
  end

  # Fonctions

  # Creation d un utilisateur
  def create_single_user(lastname, firstname, mail, file = @@passwd_users_file)
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
      end
    end
    result
  end

  # Concatenation du prenom et du nom en downcase
  def concate_lastname_firstname(lastname, firstname)
    # Suppression des espaces
    lastname = remove_special_accent(lastname)
    firstname = remove_special_accent(firstname)

    if lastname.blank?
      firstname
    elsif firstname.blank?
      lastname
    else
      firstname + '.' + lastname
    end

  end

  def remove_special_accent(string)
    return '' unless string
    
    string = string.downcase
    string = string.gsub(/[éèëêÈÉ]/, 'e')
    string = string.gsub(/[âäà]/, 'a')
    string = string.gsub(/[öô]/, 'o')
    string = string.gsub(/[ûüù]/, 'u')
    string = string.gsub(/[ïî]/, 'i')
    string = string.gsub(/[çÇ]/, 'c')
    string = string.gsub(/[\s']/, '')
    string = string.gsub(/[\s]/, '')
    string = string.gsub(/[ ]/, '')
    string
  end

  # Generate a password with 8 characters
  def generate_password
    value = ''

    8.times { value  << (97 + rand(25)).chr }
      
    value
  end
end
