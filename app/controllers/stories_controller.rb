class StoriesController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
    #FIXME_AB: Form doesn't intimate about the required fields
  end

  def create
    if @project.save_story(project_params)
      redirect_to info_project_url(@project)
    else
      render action: :new
    end
  end

  private

    def project_params
      params.require(:project).permit(:story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq])
    end

end