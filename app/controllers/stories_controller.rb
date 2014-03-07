class StoriesController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
    if @project.story.nil?
      @story = @project.build_story
    else
      @story = @project.story
    end
  end

  def create
    if @project.save_story(project_params)
      redirect_to info_project_path(@project)
    else
      @story = @project.build_story(project_params)
      @story.valid?
      render action: :new
    end
  end

  private

    def project_params
      params.require(:project).permit(:story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq])
    end

end