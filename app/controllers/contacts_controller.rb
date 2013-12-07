class ContactsController < ApplicationController

  def gmail_callback
    @contacts = request.env['omnicontacts.contacts']
    #FIXME_AB: scopes can be used. Time.now being called two times?
    #FIXED: scopes being used
    @projects = Project.by_user(current_user.id).approved.published(Time.now)
  end

  def send_email
    @to_list = params[:emails]
    @message = params[:message]
    @project = Project.find(params[:project])
    #FIXME_AB: repetition for finding user
    #FIXED: using current_user method
    ProjectPromoter.promote(@to_list, @message, current_user, @project).deliver
    redirect_to projects_path, notice: 'Your email was successfully sent'
  end

end
