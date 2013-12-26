class RewardsController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:new, :create]
  before_action :validate_owner, only: [:new, :create]

  def new
  end

  def create
    respond_to do |format|
      if @project.save_rewards(project_params)
        format.html { redirect_to project_url(@project), notice: "Project #{@project.title} was successfully created/updated." }
        format.json { render action: :show, status: :created, location: @project }
      else
        format.html { render action: :new }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  private

    def project_params
      params.require(:project).permit(:rewards_attributes => [:id, :minimum_amount, :description, :estimated_delivery_on, :shipping, :quantity])
    end

end
