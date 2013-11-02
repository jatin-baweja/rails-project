class Admin::ProjectsController < Admin::SessionsController
  skip_before_action :authorize
  before_action :admin_authorize

  def pending_for_approval
    @projects = Project.where(:pending_approval => true)
  end

  def approve
    @project = Project.find(params[:id])
    @project.pending_approval = false
    @project.save
  end

end
