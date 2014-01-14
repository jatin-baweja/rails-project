class RenamePictureInImage < ActiveRecord::Migration
  def change
    rename_column :images, :picture_file_name, :attachment_file_name
    rename_column :images, :picture_content_type, :attachment_content_type
    rename_column :images, :picture_file_size, :attachment_file_size
    rename_column :images, :picture_updated_at, :attachment_updated_at
  end
end
