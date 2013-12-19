class Admin::ProjectsController < Admin::BaseController
  before_action :set_project, only: [:approve, :reject]

  def pending_for_approval
    #FIXME_AB: Project.pending_for_approval. add scope
    #FIXED: scope used
    @projects = Project.order('updated_at DESC').group_by(&:project_state)
  end

  def approve
    #FIXME_AB: Time.now?
    #FIXED: Using Time.current
    #FIXME_AB: Too much of logic going here. You should have @project.approve! which should approve the project. In case it can not it should return false
    #FIXED: created admin_approve method
    if @project.admin_approve
      @project.set_publishing_delayed_job
      @project.set_funding_delayed_job
    else
      redirect_to project_path(@project), alert: 'The project could not be approved.'
    end
    #FIXME_AB: what if project is not saved?. After implementing my comment what if approve! returns false?. Should always think of the else part of the logic
    #FIXED: Added else condition
  end

  def reject
    #FIXME_AB: Why not @project.reject!. Implement as above
    #FIXED: Created admin_reject method
    if !@project.admin_reject
      redirect_to project_path(@project), alert: 'The project failed to be rejected'
    end
  end

  #FIXME_AB: Project.find is done two times in this controller. better to have before_action. Also what if project is not found with that id?
  #FIXED: Added set_project method

  private

    def set_project
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to projects_path, alert: "No project found with id #{ params[:id] }"
    end

end
