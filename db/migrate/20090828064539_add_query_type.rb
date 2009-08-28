class AddQueryType < ActiveRecord::Migration
  def self.up
    add_column :queries, :query_type, :string
  end

  def self.down
    removed_column :queries, :query_type
  end
end
