class ProjectStatusNotifier < ActionMailer::Base
  default from: default_sender_email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.published.subject
  #
  def published(project)
    @project = project
    mail_with_subject("Project #{project.title} published on #{ APP_NAME }", project)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.failed.subject
  #
  def failed(project)
    @project = project
    mail_with_subject("Project #{project.title} failed to generate funding on #{ APP_NAME }", project)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.project_status_notifier.funded.subject
  #
  def funded(project)
    @project = project
    mail_with_subject("Congratulations! Your project #{project.title} was successfully funded on #{ APP_NAME }", project)
  end

  private

    def mail_with_subject(subject, project)
      mail to: project.owner.email, subject: subject
    end

end
