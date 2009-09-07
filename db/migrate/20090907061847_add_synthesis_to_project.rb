class AddSynthesisToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :synthesis, :text
  end

  def self.down
    remove_column :projects, :synthesis
  end
end
