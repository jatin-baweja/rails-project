class MoveVideoToProjects < ActiveRecord::Migration

  def up
    add_column :projects, :video, :string
    @projects = Project.all
    @projects.each do |project|
      if !project.story.nil? && !project.story.video.nil?
        project.video = project.story.video
        project.save
      end
    end
    remove_column :stories, :video
  end

  def down
    add_column :stories, :video, :string
    @stories = Story.all
    @stories.each do |story|
      if !story.project.nil? && !story.project.video.nil?
        story.video = story.project.video
        story.save
      end
    end
    remove_column :projects, :video
  end

end
