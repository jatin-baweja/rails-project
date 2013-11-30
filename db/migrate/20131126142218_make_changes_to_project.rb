class MakeChangesToProject < ActiveRecord::Migration
  def change
    remove_column :projects, :name, :string
    rename_column :projects, :pending_approval, :approved
    rename_column :projects, :publish_on, :published_at
    rename_column :projects, :video, :video_url
  end
end
