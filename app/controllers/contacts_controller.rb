class ContactsController < ApplicationController
  include Projects::Setter

  before_action :set_project, only: [:import_instructions, :get_gmail_contacts]
  before_action :set_project_from_session, only: [:gmail_callback, :send_email]
  before_action :check_accessibility, only: [:import_instructions, :get_gmail_contacts, :gmail_callback, :send_email]

  def import_instructions
  end

  def get_gmail_contacts
    session[:promotion_project_id] = params[:id]
    redirect_to '/contacts/gmail'
  end

  def gmail_callback
    @contacts = request.env['omnicontacts.contacts']
  end

  def failure
    redirect_to root_url, alert: 'Your contacts could not be retrieved'
  end
  
  def send_email
    session[:promotion_project_id] = nil
    if params[:emails].present?
      params[:emails].each do |email|
        Delayed::Job.enqueue(ProjectPromoterJob.new(email, params[:message], current_user, @project))
      end
      flash[:notice] = "Your email was sent to your contacts"
    else
      flash[:alert] = "You did not select any contacts"
    end
    redirect_to projects_path
  end

  private

    def set_project_from_session
      unless (@project = Project.find_by_permalink(session[:promotion_project_id]))
        redirect_to root_path, "Project Not Found"
      end
    end

    def check_accessibility
      if (anonymous? || !@project.owner?(current_user))
        redirect_to root_path, "Access Denied"
      end
    end

end
