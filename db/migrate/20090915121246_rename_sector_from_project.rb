class RenameSectorFromProject < ActiveRecord::Migration
  def self.up
    rename_column :projects,:ssector_id, :sector
  end

  def self.down
    rename_column :projects,:sector ,:sector_id
  end
end
