class ModifyNameProjectType < ActiveRecord::Migration
  def self.up
    change_column(:projects, :name, :string)
    change_column(:projects, :acronym, :string,:limit=>30)
  end

  def self.down
    change_column(:projects, :name, :string,:limit=>30)
    change_column(:projects, :acronym, :string)
  end
end
