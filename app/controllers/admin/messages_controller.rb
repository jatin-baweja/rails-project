class Admin::MessagesController < Admin::BaseController
  include Projects::Callbacks

  before_action :set_project, only: [:admin_conversation, :create_admin_conversation]
  skip_before_action :admin_authorize, only: [:admin_conversation]
  before_action :set_messages, only: [:admin_conversation, :create_admin_conversation]

  def admin_conversation
    respond_to do |format|
      format.json { render json: @messages.to_json(:include => { :child_messages => { :only => :unread }, :from_user => { :only => :name }, :project => { :only => :title } }, :only => [:id, :subject, :updated_at]) }
    end
  end

  def create_admin_conversation
    to_user = User.find(@project.owner_id)
    message = @project.messages.build(conversation_params)
    message.sent(current_user, to_user)
    render action: :admin_conversation
  end

  private

    def set_messages
      @messages = @project.messages.parent_messages.order('updated_at DESC')
    end

    def conversation_params
      params.require(:message).permit(:id, :subject, :content)
    end

end
