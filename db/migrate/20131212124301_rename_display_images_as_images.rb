class RenameDisplayImagesAsImages < ActiveRecord::Migration
  def change
    rename_table :display_images, :images
  end
end
