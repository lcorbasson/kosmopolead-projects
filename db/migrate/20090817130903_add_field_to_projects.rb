class AddFieldToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :estimated_time, :integer
    add_column :projects, :author_id, :integer
    add_column :projects, :acronym, :text
    add_column :projects, :watched_by, :integer
    add_column :projects, :build_by, :integer
  end

  def self.down
    remove_column :projects, :build_by
    remove_column :projects, :watched_by
    remove_column :projects, :acronym
    remove_column :projects, :author_id
    remove_column :projects, :estimated_time
  end
end
