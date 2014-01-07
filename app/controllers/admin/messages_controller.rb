class Admin::MessagesController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:index, :create]
  skip_before_action :admin_authorize, only: [:index]
  before_action :set_messages, only: [:index, :create]

  def index
    respond_to do |format|
      format.json { render json: @messages.to_json(:include => { :replies => { :only => :unread }, :sender => { :only => :name }, :project => { :only => :title } }, :only => [:id, :subject, :updated_at]) }
    end
  end

  def create
    message = @project.messages.create(conversation_params.merge({sender: current_user, receiver: @project.owner}))
    if message.valid?
      render js: %($('#messages-button').click();)
    else
      render js: %(alert('The message could not be sent.');)
    end
  end

  private

    def set_messages
      @messages = @project.messages.parent_messages.order('updated_at DESC')
    end

    def conversation_params
      params.require(:message).permit(:id, :subject, :content)
    end

end
