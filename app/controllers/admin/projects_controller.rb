class Admin::ProjectsController < Admin::SessionsController
  skip_before_action :authorize
  before_action :admin_authorize

  def pending_for_approval
    @projects = Project.where(pending_approval: true, rejected: false, editing: false).order('created_at ASC')
  end

  def approve
    @project = Project.find(params[:id])
    @project.publish_on = Time.now if @project.publish_on.nil?
    @project.pending_approval = false
    @project.save
  end

  def reject
    @project = Project.find(params[:id])
    @project.rejected = true
    @project.save
  end

end
