class CreateProjectPartners < ActiveRecord::Migration
  def self.up   
     create_table :project_partners, :force => true do |t|
      t.integer   :project_id
      t.integer   :partner_id
      t.timestamps
    end
  end

  def self.down
    drop_table :project_partners
  end
end
