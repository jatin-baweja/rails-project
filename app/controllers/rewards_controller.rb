class RewardsController < ApplicationController
  before_action :set_project, only: [:choose]

  #FIXME_AB: I have some concerns on the method name
  def choose
    @rewards = @project.rewards
  end

  private

    def set_project
      #FIXME_AB: What if project not found with the id. We should handle this everywhere 
      @project = Project.find(params[:id])
    end

end
