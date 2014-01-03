class Admin::ProjectsController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:approve, :reject]

  def index
    @projects = Project.includes(:images).order('updated_at DESC')..page(params[:page]).per_page(DEFAULT_PER_PAGE_RESULT_COUNT)
  end

  def approve
      #FIXME_AB: These two things also be the part of model, in callback of the AASM
      #FIXED: Added to after callback for approve event
    unless @project.approve!
      flash[:alert] = 'The project could not be approved'
      #FIXME_AB: Why do we need render js in these two actions, we have the erb.js files for these actions
      #FIXED: In case project fails to be accepted or rejected, it should display error message and not js.erb file
      render js: %(window.location.href = '#{ project_path(@project) }')
    end
  end

  def reject
    unless @project.reject!
      flash[:alert] = 'The project failed to be rejected'
      render js: %(window.location.href = '#{ project_path(@project) }')
    end
  end

end
