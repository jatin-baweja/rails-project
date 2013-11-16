class MessageNotifier < ActionMailer::Base
  default from: "jatinbaweja90@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.message_notifier.sent.subject
  #
  def sent(to_user, from_user, project, message)
    @to_user = to_user
    @from_user = from_user
    @for_project = project
    @message = message

    mail to: to_user.email, subject: 'New Message'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.message_notifier.rejected.subject
  #
  def rejected(to_user, rejection_reason)

    mail to: to_user.email, subject: 'Project Rejected by Admin'
  end
end
