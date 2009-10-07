class AddPartnerIdToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :partner_id, :int
  end

  def self.down
    remove_colum :projects, :partner_id
  end
end
