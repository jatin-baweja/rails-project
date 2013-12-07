class Admin::ProjectsController < Admin::BaseController

  def pending_for_approval
    @projects = Project.where(project_state: 'submitted').order('created_at ASC')
  end

  def approve
    @project = Project.find(params[:id])
    @project.published_at = Time.now if @project.published_at.nil? || @project.published_at < Time.now
    @project.deadline = @project.published_at + @project.duration.days
    @project.approve
    if @project.save
      Delayed::Job.enqueue(PublishProjectJob.new(@project), 0, @project.published_at + 5.minutes)
      Delayed::Job.enqueue(ProjectFundingJob.new(@project), 0, @project.deadline + 5.minutes)
    end
  end

  def reject
    @project = Project.find(params[:id])
    @project.reject
    @project.save
  end

end
