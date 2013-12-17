class RewardsController < ApplicationController
  before_action :set_draft_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
  end

  def create
    @project.step = 4;
    respond_to do |format|
      if @project.update(project_params)
        @project.submit!
        format.html { redirect_to project_url(@project.id),
          notice: "Project #{@project.title} was successfully created/updated." }
        format.json { render action: 'show',
          status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  #FIXME_AB: I have some concerns on the method name
  #FIXED: Choosing rewards on pledge page itself, deleted choose action

  private

      #FIXME_AB: What if project not found with the id. We should handle this everywhere 
      #FIXED: Handling not found cases

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
      params.require(:project).permit(:rewards_attributes => [:id, :minimum_amount, :description, :estimated_delivery_on, :shipping, :quantity])
    end

end
