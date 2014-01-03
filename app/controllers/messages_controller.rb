class MessagesController < ApplicationController
  before_action :set_message, only: [:create, :show]

  def index
    @messages = current_user.inbox
  end

  def show
    @reply_message = Message.new
  end

  def create
    message = current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
    if message.new_record?
      redirect_to message_path(@message)
    else
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
