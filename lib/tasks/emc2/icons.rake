# EMC2 Tasks
namespace :emc2 do
  
  # Create icons for partners
  task :create_icons => :environment do
    # Instanciation de variables
    general_path = "#{RAILS_ROOT}/lib/tasks/emc2/icons/"
    ext_file = ".*"

    # Recuperation de la liste des icons
    icons = Dir.glob(general_path + "*#{ext_file}")

    # Pour chaque icon dans le dossier lib/tasks/emc2/icons/
    icons.each do |icon|
      # Recuperation de l ID du logo
      icon_id = File.basename("#{icon}", "#{ext_file}")

      # Recuperation de l object Partner
      partner = Partner.find(icon_id)

      # Si l object partner est present
      if partner
        partner.update_attribute(:logo, File.new(icon))
      end
    end
  end
end
