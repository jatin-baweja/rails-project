class MessagesController < ApplicationController
  before_action :set_message, only: [:create, :show]
  after_action :mark_read, only: [:show]

  def index
    #FIXME_AB: I am seeing /messages as blank page
    @messages = current_user.inbox.includes(:project, :sender, :receiver, :replies)
  end

  def show
    @reply_message = current_user.sent_messages.build
    respond_to do |format|
      format.js {
        render json: @message.to_json(
          :include => {
            :replies => {
              :only => [:content, :created_at],
              :include => {
                :sender => { :only => [:name] },
                :receiver => { :only => [:name] }
                }
            },
            :sender => {
              :only => [:name]
            },
            :receiver => {
              :only => [:name]
            }
          },
          :only => [:id, :subject, :content, :created_at]
          )
      }
      format.html {}
    end
  end

  def create
    @reply_message = current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
    if @reply_message.persisted?
      redirect_to message_path(@message)
    else
      render action: :show
    end
  end

  private

    def set_message
      @message = Message.parent_messages.includes(:replies => [:sender, :receiver]).find_by(id: params[:id])
      if @message.nil?
        redirect_to messages_path, alert: 'No message to display'
      end
    end

    def mark_read
      if @message.last_receiver?(current_user)
        @message.mark_thread_as_read
      end
    end

    def message_params
      params.require(:message).permit(:id, :content)
    end

end
