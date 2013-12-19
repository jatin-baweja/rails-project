class SubscriptionsController < ApplicationController
  #FIXME_AB: Why do I need to be logged in to be able to subscribe?
  #FIXED: All actions to skip authorize by default
  skip_before_action :authorize
  before_action :check_params, only: [:create]

  #FIXME_AB: Both action name do not justify their working. Why not new and create.
  #FIXED: Changed names to new and create
  def new
    if logged_in?
      @email = current_user.email
    end
  end

  def create
    Delayed::Job.enqueue(SubscribeUserJob.new(params[:email], params[:first_name], params[:last_name]))
    redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
  end

  private

    def check_params
      redirect = false
      if !params[:email].match(REGEX_PATTERN[:email])
        flash[:alert] = 'Email format incorrect'
        redirect = true
      elsif params[:first_name].blank? || params[:last_name].blank?
        flash[:alert] = 'Name fields cannot be empty'
        redirect = true
      end
      redirect_to action: :weekly if redirect
    end

end
