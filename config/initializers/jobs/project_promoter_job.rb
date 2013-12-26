class ProjectPromoterJob < Struct.new(:email, :message, :user, :project)

  def perform
    ProjectPromoter.promote(email, message, user, project).deliver
  end

end
