class PledgeNotifierJob < Struct.new(:pledge, :project, :user)

  def perform
    if project.approved?
      PledgeNotifier.inform_pledger(user, pledge.amount, project).deliver
      PledgeNotifier.inform_project_owner(project, pledge.amount).deliver
    end
  end

end
