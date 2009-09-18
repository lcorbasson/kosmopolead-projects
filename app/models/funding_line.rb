class FundingLine < ActiveRecord::Base

  # -- relations
  
  belongs_to :project


  # -- validations

  validates_numericality_of :montant_demande, :montant_accorde,:montant_libere, :allow_nil => true


   def validate
    if self.date_liberation.nil? && @attributes['date_liberation'] && !@attributes['date_liberation'].empty?
      errors.add :date_liberation, :activerecord_error_not_a_date
    end
    if self.date_accord.nil? && @attributes['date_accord'] && !@attributes['date_accord'].empty?
      errors.add :date_accord, :activerecord_error_not_a_date
    end
   end

end
