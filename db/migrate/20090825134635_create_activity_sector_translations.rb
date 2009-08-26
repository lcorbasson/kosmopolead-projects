class CreateActivitySectorTranslations < ActiveRecord::Migration
  def self.up
    create_table :activity_sector_translations do |t|
      t.text :name
      t.text :description
      t.text :local
      t.integer :activity_sector_id

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_sector_translations
  end
end
