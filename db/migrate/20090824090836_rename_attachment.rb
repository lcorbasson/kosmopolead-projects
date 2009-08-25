class RenameAttachment < ActiveRecord::Migration
  def self.up
    rename_table :attachments,:file_attachments
  end

  def self.down
    rename_table :file_attachments,:attachments
  end
end
