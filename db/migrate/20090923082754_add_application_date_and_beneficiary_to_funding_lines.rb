class AddApplicationDateAndBeneficiaryToFundingLines < ActiveRecord::Migration
  def self.up
    add_column :funding_lines, :application_date, :date
    add_column :funding_lines, :beneficiary, :string
  end

  def self.down
    remove_column :funding_lines, :application_date
    remove_column :funding_lines, :beneficiary
  end
end
