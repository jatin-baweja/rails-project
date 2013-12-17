class MoveVideoToProjects < ActiveRecord::Migration

  def up
    add_column :projects, :video, :string
    remove_column :stories, :video
  end

  def down
    add_column :stories, :video, :string
    remove_column :projects, :video
  end

end
