class Admin::ProjectsController < Admin::BaseController

  def pending_for_approval
    #FIXME_AB: Project.pending_for_approval. add scope
    @projects = Project.where(project_state: 'submitted').order('created_at ASC')
  end

  def approve
    @project = Project.find(params[:id])
    #FIXME_AB: Time.now?
    #FIXME_AB: Too much of logic going here. You should have @project.approve! which should approve the project. In case it can not it should return false
    @project.published_at = Time.now if @project.published_at.nil? || @project.published_at < Time.now
    @project.deadline = @project.published_at + @project.duration.days
    @project.approve
    if @project.save
      Delayed::Job.enqueue(PublishProjectJob.new(@project), 0, @project.published_at + 5.minutes)
      Delayed::Job.enqueue(ProjectFundingJob.new(@project), 0, @project.deadline + 5.minutes)
    end
    #FIXME_AB: what if project is not saved?. After implementing my comment what if approve! returns false?. Should always think of the else part of the logic
  end


  def reject
    @project = Project.find(params[:id])
    #FIXME_AB: Why not @project.reject!. Implement as above
    @project.reject
    @project.save
  end

  #FIXME_AB: Project.find is done two times in this controller. better to have before_action. Also what if project is not found with that id?

end
