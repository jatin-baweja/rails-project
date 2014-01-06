class MessagesController < ApplicationController
  before_action :set_message, only: [:create, :show]

  def index
    #FIXME_AB: I am seeing /messages as blank page
    @messages = current_user.inbox
  end

  def show
    #FIXME_AB: I think it should be current_user.sent_messages.build
    @reply_message = Message.new
  end

  def create
    #FIXME_AB: Please check the logic of this action. There is something wrong
    message = current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
    if message.new_record?
      redirect_to message_path(@message)
    else
      #FIXME_AB: I should remain on the same page where I was and see the actual error.
      redirect_to messages_url, alert: "There was an error sending that message"
    end
  end

  private

    def set_message
      @message = Message.parent_messages.find_by(id: params[:id])
      if @message.nil?
        redirect_to messages_url, alert: 'No message to display'
      end
    end

    def message_params
      params.require(:message).permit(:id, :content)
    end

end
