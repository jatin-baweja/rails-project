class StoriesController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
  end

  def create
    respond_to do |format|
      if @project.save_story(project_params)
        format.html { redirect_to info_project_url(@project) }
      else
        format.html { render action: :new }
      end
    end
  end

  private

    def project_params
      params.require(:project).permit(:story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq])
    end

end