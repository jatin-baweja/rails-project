class StoriesController < ApplicationController
  before_action :set_draft_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
  end

  def create
    @project.step = 2;
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to info_project_url(@project.id) }
        format.json { render action: :show, status: :created, location: @project }
      else
        format.html { render action: :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_draft_project
      if !(@project = Project.find_by(id: params[:id]))
        redirect_to projects_path, alert: 'No such project found'
      end
    end

    def validate_owner
      if(@project.owner_id != current_user.id)
        redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
      end
    end

    def project_params
      params.require(:project).permit(:story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq])
    end

end