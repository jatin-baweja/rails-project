class PledgeNotifier < ActionMailer::Base
  default from: default_sender_email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.pledge_notifier.inform_pledger.subject
  #
  def pledge_by_user(pledger, amount, project)
    @pledger = pledger
    @amount = amount
    @project = project
    mail to: pledger.email, subject: "You have successfully pledged for project #{ project.title }"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.pledge_notifier.inform_project_owner.subject
  #
  def project_pledged(project, amount)
    @amount = amount
    @project = project
    @project_owner = project.user
    mail to: @project_owner.email, subject: "Your project #{ project.title } was pledged"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.pledge_notifier.charged.subject
  #
  def user_card_charged(user, amount, project)
    @user = user
    @amount = amount
    @project = project
    mail to: user.email, subject: "Your card has been successfully charged"
  end
end
