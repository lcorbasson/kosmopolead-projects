class FundingLine < ActiveRecord::Base

  # -- relations
  
  belongs_to :project


  # -- validations

  validates_numericality_of :asked_amount, :agreed_amount,:released_amount, :allow_nil => true


   def validate
    if self.released_on.nil? && @attributes['released_on'] && !@attributes['released_on'].empty?
      errors.add :released_on, :activerecord_error_not_a_date
    end
    if self.agreed_on.nil? && @attributes['agreed_on'] && !@attributes['agreed_on'].empty?
      errors.add :agreed_on, :activerecord_error_not_a_date
    end
   end

end
