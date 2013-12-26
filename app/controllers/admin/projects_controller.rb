class Admin::ProjectsController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:approve, :reject]

  def pending_for_approval
    @projects = Project.order('updated_at DESC').group_by(&:project_state)
  end

  def approve
    if @project.approved_by_admin
      @project.set_publishing_delayed_job
      @project.set_funding_delayed_job
    else
      redirect_to project_path(@project), alert: 'The project could not be approved.'
    end
  end

  def reject
    if !@project.rejected_by_admin
      redirect_to project_path(@project), alert: 'The project failed to be rejected'
    end
  end

end
