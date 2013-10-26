class AddAttachmentImageToProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :image
    change_table :projects do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :projects, :image
    add_column :projects, :image, :string
  end
end
