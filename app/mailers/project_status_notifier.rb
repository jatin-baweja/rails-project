class ProjectStatusNotifier < ActionMailer::Base
  default from: default_sender_email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.published.subject
  #
  def published(project)
    @project = project
    mail to: project.owner.email, subject: "Project #{project.title} published on Kicklone"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.failed.subject
  #
  def failed(project)
    @project = project
    mail to: project.owner.email, subject: "Project #{project.title} failed to generate funding on Kicklone"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.funded.subject
  #
  def funded(project)
    @project = project
    mail to: project.owner.email, subject: "Congratulations! Your project #{project.title} was successfully funded on Kicklone"
  end
end
