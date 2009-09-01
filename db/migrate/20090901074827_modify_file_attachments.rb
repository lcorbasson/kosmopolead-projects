class ModifyFileAttachments < ActiveRecord::Migration
  def self.up
    rename_column :file_attachments, :filename,:file_file_name
    rename_column :file_attachments, :content_type,:file_content_type
    rename_column :file_attachments, :filesize,:file_file_size
    add_column :file_attachments, :file_updated_at,:string

    remove_column :file_attachments, :disk_filename
  end

  def self.down
    rename_column :file_attachments, :file_file_name,:filename
    rename_column :file_attachments, :file_content_type,:content_type
    rename_column :file_attachments, :file_file_size,:filesize
    remove_column :file_attachments, :file_updated_at

    add_column :file_attachments, :disk_filename,:string
  end
end
