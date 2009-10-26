# EMC2 Tasks
namespace :emc2 do
  
  # Create icons for partners
  task :import_poles => :environment do
    # Chargement de la librairie FasterCSV
    require 'fastercsv'
    # Definition du file path
    poles_file = "#{RAILS_ROOT}/lib/tasks/emc2/emc2_liste_poles.csv"

    # Verification de l existance du fichier
    unless File.exist?(poles_file)
      p "EMC2 Poles File not found"
      exit
    end

    # Chargement de la communaute EMC2
    emc2 = Community.find_by_name('EMC2')
    
    # Si la communaute a ete trouvee
    if emc2
      # Definition de la variable de retour
      poles = []

      # Ouverture du fichier a parser avec FasterCSV
      FasterCSV.foreach(poles_file) do |row|
        # Instanciation de variable
        pole = row[0]

        # Inclusion du pole dans la liste des poles
        poles << pole
      end
    
      # Modification des possibles values pour les champs Labellisation et Pole Leader
      emc2.custom_fields.find_by_name("Labellisation").update_attribute(:possible_values, poles)
      emc2.custom_fields.find_by_name("Pôle Leader").update_attribute(:possible_values, poles)
    end
  end
end
