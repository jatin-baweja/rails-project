class ProjectPromoter < ActionMailer::Base
  default from: "xyz@sample.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_promoter.promote.subject
  #
  def promote(to_list, message, user, project)
    @message = message
    @user = user
    @project = project

    mail to: to_list, subject: "#{user.name} wants you to know about his new Project"
  end
end
