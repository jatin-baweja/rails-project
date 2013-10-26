class AddAttachmentVideoToStories < ActiveRecord::Migration
  def self.up
    remove_column :stories, :video
    change_table :stories do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :stories, :video
    add_column :stories, :video, :string
  end

end
