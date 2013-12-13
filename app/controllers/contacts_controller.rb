class ContactsController < ApplicationController

  def gmail_callback
    @contacts = request.env['omnicontacts.contacts']
    #FIXME_AB: We can also create one more scope called live which will return all the live projects;
    #   scope :live, -> {approved.published(Time.current).still_active}
    # Project.owned_by(current_user).live
    # Also we can move ahead and add one more scope :live_for_user in the same way
    @projects = Project.owned_by(current_user).approved.published(Time.current).still_active
  end

  def send_email
    @to_list = params[:emails]
    @message = params[:message]
    @project = Project.find(params[:project])
    ProjectPromoter.promote(@to_list, @message, current_user, @project).deliver
    redirect_to projects_path, notice: 'Your email was successfully sent'
  end

end
