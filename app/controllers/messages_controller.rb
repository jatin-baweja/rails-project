class MessagesController < ApplicationController
  before_action :set_message, only: [:create, :show]

  def index
    @messages = (current_user.sent_messages.parent_messages + current_user.received_messages.parent_messages).sort { |x,y| y.updated_at <=> x.updated_at }
  end

  def show
    @child_message = @message.child_messages.build
  end

  def create
    if created_message = current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
      redirect_to message_path(@message)
    else
      redirect_to messages_url, alert: "There was an error sending that message"
    end
  end

  private

    def set_message
      @message = Message.parent_messages.find(params[:id])
      #FIXME_AB: What if message is not found with this email
      #FIXED: Added exception handling
    rescue ActiveRecord::RecordNotFound
      redirect_to messages_url, alert: 'Invalid message id'
    end

    def message_params
      params.require(:message).permit(:id, :content)
    end

    #FIXME_AB: I don't think we would need this function or need to do things this way. Please explain
    #FIXED: Added callbacks and merged parent_id in message_params

end
