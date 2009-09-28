class MassRenameFrenchColumnsIntoEnglishColumnsOnFundingLines < ActiveRecord::Migration
  def self.up
    rename_column :funding_lines, :financeur, :backer
    rename_column :funding_lines, :correspondant_financeur, :backer_correspondent
    rename_column :funding_lines, :application_date, :asked_on
    rename_column :funding_lines, :montant_demande, :asked_amount
    rename_column :funding_lines, :date_accord, :agreed_on
    rename_column :funding_lines, :montant_accorde, :agreed_amount
    rename_column :funding_lines, :date_liberation, :released_on
    rename_column :funding_lines, :montant_libere, :released_amount
  end

  def self.down
    rename_column :funding_lines, :backer, :financeur
    rename_column :funding_lines, :backer_correspondent, :correspondant_financeur
    rename_column :funding_lines, :asked_on, :application_date
    rename_column :funding_lines, :asked_amount, :montant_demande
    rename_column :funding_lines, :agreed_on, :date_accord
    rename_column :funding_lines, :agreed_amount, :montant_accorde
    rename_column :funding_lines, :released_on, :date_liberation
    rename_column :funding_lines, :released_amount, :montant_libere
  end
end
