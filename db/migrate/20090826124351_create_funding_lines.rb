class CreateFundingLines < ActiveRecord::Migration
  def self.up
    create_table :funding_lines, :force => true do |t|
      t.integer   :project_id
      t.string    :aap
      t.string    :financeur
      t.string    :correspondant_financeur
      t.decimal   :montant_demande
      t.string    :type
      t.date      :date_accord
      t.decimal   :montant_accorde
      t.date      :date_liberation
      t.decimal   :montant_libere
      t.timestamps
    end
  end

  def self.down
    drop_table :funding_lines
  end
end
