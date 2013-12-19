class MessagesController < ApplicationController
  before_action :set_project, only: [:admin_conversation, :create_admin_conversation]
  before_action :validate_admin, only: [:create_admin_conversation]
  before_action :set_params_for_conversation, only: [:admin_conversation]
  before_action :set_message, only: [:create, :show]

  def index
    @messages = current_user.inbox
  end

  def show
    @child_message = @message.child_messages.build
  end

  def create
    if current_user.sent_messages.create(message_params.merge(parent_id: @message.id.to_s))
      redirect_to message_path(@message)
    else
      redirect_to messages_url, alert: "There was an error sending that message"
    end
  end

  def admin_conversation
    @messages = @project.messages.parent_messages.order('updated_at DESC')
    respond_to do |format|
      format.js {}
    end
  end

  def create_admin_conversation
    @from = current_user
    @to = User.find(@project.owner_id)
    @message = @project.messages.build(conversation_params)
    @message.from_user_id = @from.id
    @message.to_user_id = @to.id
    if @message.save
      MessageNotifier.sent(@to, @from, @project, @message).deliver
    end
    redirect_to admin_conversation_project_url
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

    def set_project
      #FIXME_AB: Logic of this method is complex, it can be simplified
      if !(@project = Project.find_by_permalink(params[:id]))
        if !(@project = Project.find_by(id: params[:id]))
          redirect_to projects_path, alert: 'No such project found'
        end
      end
    end

    def validate_admin
      if(!current_user.admin?)
        redirect_to project_path(@project), notice: "Access Denied"
      end
    end

    def set_params_for_conversation
      @user = @project.user
      @messages = @project.messages.order(:created_at)
      @parent_message = @messages.first
      @message = @project.messages.build
    end

    def conversation_params
      params.require(:message).permit(:id, :subject, :content)
    end

end
