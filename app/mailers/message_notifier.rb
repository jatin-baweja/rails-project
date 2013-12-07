class MessageNotifier < ActionMailer::Base
  #FIXME_AB: Don't hard code such things
  #FIXED: Added mail initializer
  default from: DEFAULT_FROM_EMAIL

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
    #FIXME_AB: I think message how have a subject, can we use that as the email subject?
    #FIXED: Using that as email subject
    mail to: to_user.email, subject: "New Message: #{ @message.subject }"
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
