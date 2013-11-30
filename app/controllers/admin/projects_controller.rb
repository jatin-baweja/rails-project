class Admin::ProjectsController < Admin::SessionsController
  skip_before_action :authorize
  before_action :admin_authorize

  def pending_for_approval
    @projects = Project.where(project_state: 'submitted').order('created_at ASC')
  end

  def approve
    @project = Project.find(params[:id])
    @project.published_at = Time.now if @project.published_at.nil?
    @project.approve
    @project.save
  end

  def reject
    @project = Project.find(params[:id])
    @project.reject
    @project.save
  end

end
