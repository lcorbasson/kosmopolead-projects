class CreateCommunities < ActiveRecord::Migration
  def self.up
    create_table :communities do |t|
      t.integer :parent_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :communities
  end
end
