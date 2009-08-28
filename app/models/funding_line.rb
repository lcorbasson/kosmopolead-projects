class FundingLine < ActiveRecord::Base
  
  belongs_to :project

#  validates_presence_of :aap,:financeur,:correspondant_financeur,:montant_demande, :type,:date_accord,:montant_accorde,:date_liberation,:montant_libere
end
