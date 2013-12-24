class Admin::ProjectsController < Admin::BaseController
  include Projects::Setter

  before_action :set_project, only: [:approve, :reject]

  def pending_for_approval
    @projects = Project.order('updated_at DESC').group_by(&:project_state)
  end

  def approve
    if @project.admin_approve
      @project.set_publishing_delayed_job
      @project.set_funding_delayed_job
    else
      redirect_to project_path(@project), alert: 'The project could not be approved.'
    end
  end

  def reject
    if !@project.admin_reject
      redirect_to project_path(@project), alert: 'The project failed to be rejected'
    end
  end

  private

    # def set_project
    #   unless @project = Project.find_by(id: params[:id])
    #     redirect_to projects_path, alert: "No project found with id #{ params[:id] }"
    #   end
    # end

end
