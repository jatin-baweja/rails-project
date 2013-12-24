class SubscriptionsController < ApplicationController
  skip_before_action :authorize

  def new
    @subscriber = Subscriber.new
  end

  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.valid?
      redirect_to root_path, notice: 'You have successfully subscribed to our mailing list'
    else
      render action: :new
    end
  end

  private

    def subscriber_params
      params.require(:subscriber).permit(:email, :first_name, :last_name)
    end

end
