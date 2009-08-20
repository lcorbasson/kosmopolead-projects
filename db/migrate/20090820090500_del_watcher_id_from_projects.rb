class DelWatcherIdFromProjects < ActiveRecord::Migration
  def self.up
    remove_column(:projects, :watched_by)
  end

  def self.down
  end
end
