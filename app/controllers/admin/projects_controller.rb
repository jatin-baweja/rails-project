class Admin::ProjectsController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:approve, :reject]

  def index
    @projects = Project.order('updated_at DESC').group_by(&:project_state)
  end

  def approve
    if @project.approved_by_admin
      #FIXME_AB: These two things also be the part of model, in callback of the AASM
      @project.set_publishing_delayed_job
      @project.set_funding_delayed_job
    else
      flash[:alert] = 'The project could not be approved'
      #FIXME_AB: Why do we need render js in these two actions, we have the erb.js files for these actions
      render js: %(window.location.href = '#{ project_path(@project) }')
    end
  end

  def reject
    if !@project.rejected_by_admin
      flash[:alert] = 'The project failed to be rejected'
      render js: %(window.location.href = '#{ project_path(@project) }')
    end
  end

end
