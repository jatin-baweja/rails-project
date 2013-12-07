class RewardsController < ApplicationController
  before_action :set_project, only: [:choose]

  def choose
    @rewards = @project.rewards
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

end
