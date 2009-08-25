class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries, :force => true do |t|
      t.string :owned_type, :limit=>20
      t.integer :owned_id
      t.timestamps
    end
    add_index :galleries, [:owned_id, :owned_type]

     create_table :photos, :force => true do |t|
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at
      t.string :name, :limit=>50
      t.integer :gallery_id
      t.timestamps
    end
  end

  def self.down
    drop_table :galleries,:photos
  end
end
