class PledgeNotifier < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.pledge_notifier.inform_pledger.subject
  #
  def inform_pledger(pledger, amount, project)
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
  def inform_project_owner(project, amount)
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
  def charged(user, amount, project)
    @user = user
    @amount = amount
    @project = project
    mail to: user.email, subject: "Your card has been successfully charged"
  end
end
