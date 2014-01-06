class Admin::MessagesController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:index, :create]
  skip_before_action :admin_authorize, only: [:index]
  before_action :set_messages, only: [:index, :create]

 #FIXME_AB: I think we can do most of the job through JS file itself and don' need to write js in erb file. Lets discuss when you are available. 
 #FIXED: Removed admin_conversation js erb file
  def index
    respond_to do |format|
      format.json { render json: @messages.to_json(:include => { :child_messages => { :only => :unread }, :sender => { :only => :name }, :project => { :only => :title } }, :only => [:id, :subject, :updated_at]) }
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
