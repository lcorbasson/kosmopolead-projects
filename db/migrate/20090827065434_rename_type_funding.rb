class RenameTypeFunding < ActiveRecord::Migration
  def self.up
    rename_column :funding_lines, :type, :funding_type
  end

  def self.down
    rename_column :funding_lines, :funding_type, :type
  end
end
