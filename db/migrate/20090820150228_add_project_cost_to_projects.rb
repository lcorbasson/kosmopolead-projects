class AddProjectCostToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :project_cost, :integer
  end

  def self.down
    remove_column :projects, :project_cost
  end
end
