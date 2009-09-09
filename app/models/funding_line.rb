class FundingLine < ActiveRecord::Base

  # -- relations
  
  belongs_to :project


  # -- validations

  validates_numericality_of :montant_demande, :montant_accorde,:montant_libere, :allow_nil => true


end
