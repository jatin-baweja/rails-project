class ContactsController < ApplicationController

  def gmail_callback
    @contacts = request.env['omnicontacts.contacts']
    #FIXME_AB: how about current_user.projects.live or current_user.owned_projects.live
    @projects = Project.live_for_user(current_user)
  end

  def failure
    redirect_to root_url, alert: 'Your contacts could not be retrieved'
  end
  
  def send_email
    @to_list = params[:emails]
    @message = params[:message]
    @project = Project.find(params[:project])
    ProjectPromoter.promote(@to_list, @message, current_user, @project).deliver
    redirect_to projects_path, notice: 'Your email was successfully sent'
  end

end
