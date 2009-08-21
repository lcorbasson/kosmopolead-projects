class AddWatcherIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :watcher_id, :integer
  end

  def self.down
    remove_column :projects, :watcher_id
  end
end
