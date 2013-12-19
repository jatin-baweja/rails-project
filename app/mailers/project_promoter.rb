class ProjectPromoter < ActionMailer::Base
  default from: default_sender_email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_promoter.promote.subject
  #
  def promote(email, message, user, project)
    @message = message
    @user = user
    @project = project

    mail to: email, subject: "#{user.name} wants you to know about his new Project"
  end
end
