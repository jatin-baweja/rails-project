class MessagesController < ApplicationController
  before_action :set_message, only: [:create, :show]

  def index
    #FIXME_AB: current_user.inbox what do you think?
    @messages = (current_user.sent_messages.parent_messages + current_user.received_messages.parent_messages).sort { |x,y| y.updated_at <=> x.updated_at }
  end

  def show
    @child_message = @message.child_messages.build
  end

  def create
    #FIXME_AB: Nice use of merge 
    #FIXME_AB: we are not using created_message local variable so why we define that
    if created_message = current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
      redirect_to message_path(@message)
    else
      redirect_to messages_url, alert: "There was an error sending that message"
    end
  end

  private

    def set_message
      @message = Message.parent_messages.find(params[:id])
      #FIXME_AB: Better use find_by and use if @message.nil? instead of active record RecordNotFound
    rescue ActiveRecord::RecordNotFound
      #FIXME_AB: From User prospective this message is of no use to me. 
      redirect_to messages_url, alert: 'Invalid message id'
    end

    def message_params
      params.require(:message).permit(:id, :content)
    end

end
