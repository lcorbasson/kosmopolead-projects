class CreatePartnerships < ActiveRecord::Migration
  def self.up
     create_table :partnerships, :force => true do |t|
      t.integer   :user_id
      t.integer   :partner_id
      t.timestamps
    end
  end

  def self.down
    drop_table :partnerships
  end
end
