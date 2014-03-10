class PledgeNotifierJob < Struct.new(:pledge, :project, :user)

  def perform
    if project.approved?
      PledgeNotifier.pledge_by_user(user, pledge.amount, project).deliver
      PledgeNotifier.inform_project_owner(project, pledge.amount).deliver
    end
  end

end
