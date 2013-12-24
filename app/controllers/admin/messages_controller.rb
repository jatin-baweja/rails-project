class Admin::MessagesController < Admin::BaseController
  include Projects::Setter

  before_action :set_project, only: [:admin_conversation, :create_admin_conversation]
  skip_before_action :admin_authorize, only: [:admin_conversation]
  before_action :set_params_for_conversation, only: [:admin_conversation]

  def admin_conversation
    @messages = @project.messages.parent_messages.order('updated_at DESC')
    respond_to do |format|
      format.js {}
    end
  end

  def create_admin_conversation
    to = User.find(@project.owner_id)
    @message = @project.messages.build(conversation_params)
    @message.sent(current_user, to)
    redirect_to admin_conversation_project_url
  end

  private

    def set_params_for_conversation
      @user = @project.owner
      @parent_message = @project.messages.order(:created_at).first
      @message = @project.messages.build
    end

    def conversation_params
      params.require(:message).permit(:id, :subject, :content)
    end

end
