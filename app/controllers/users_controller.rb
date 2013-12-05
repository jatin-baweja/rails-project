class UsersController < ApplicationController
  cache_sweeper :user_sweeper, only: [:update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :set_user_from_session, only: [:messages]
  before_action :set_message, only: [:create_message, :message]
  skip_before_action :authorize, only: [:new, :create]
  caches_action :show

  def new
    @user = User.new
  end

  def show
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user),
          #FIXME_AB: Is admin creating users? If not then following message is not appro.
          notice: "User #{@user.name} was successfully created." }
        format.json { render action: 'show',
          status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      #FIXME_AB: I can update any user?
      if @user.update(user_params)
        format.html { redirect_to user_url(@user),
          #FIXME_AB: message not appropriate
          notice: "User #{@user.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      #FIXME_AB: I can delete any user?
      @user.destroy
      flash[:notice] = "User #{@user.name} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  #FIXME_AB: Shouldn't we create a separate controller to import contacts
  def gmail_callback
    @contacts = request.env['omnicontacts.contacts']
    #FIXME_AB: scopes can be used. Time.now being called two times?
    @projects = Project.where(['owner_id = ? ',session[:user_id]]).where(approved: false).where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ? OR deadline IS NULL)', Time.now, Time.now])
  end

  def send_email
    @to_list = params[:emails]
    @message = params[:message]
    @project = params[:project]
    #FIXME_AB: repetition for finding user
    @user = User.find(session[:user_id])
    ProjectPromoter.promote(@to_list, @message, @user, @project).deliver
    redirect_to projects_path, notice: 'Your email was successfully sent'
  end

  #FIXME_AB: why messaging is being done in users controller. I think we need to have a controller for messaging?
  def messages
    @messages = (@user.sent_messages.where('parent_id IS NULL') + @user.received_messages.where('parent_id IS NULL')).sort { |x,y| y.updated_at <=> x.updated_at }
  end

  def message
    @child_message = @message.child_messages.build
  end

  def create_message
    @message.update(altered_message_params(@message))
    redirect_to message_path(@message)
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end

    def set_message
      @message = Message.find(params[:id])
      #FIXME_AB: What if message is not found with this email
    end

    def message_params
      params.require(:message).permit(:id, :content, :child_messages_attributes => [:id, :content])
    end

    #FIXME_AB: I don't think we would need this function or need to do things this way. Please explain
    def altered_message_params(parent_message)
      msg_params = message_params
      msg_params["child_messages_attributes"]["0"]["subject"] = parent_message.subject
      sending_user_id = session[:user_id] ? session[:user_id] : session[:admin_id]
      msg_params["child_messages_attributes"]["0"]["from_user_id"] = sending_user_id
      receiving_user_id = (parent_message.from_user_id == session[:user_id] || parent_message.from_user_id == session[:admin_id]) ? parent_message.to_user_id : parent_message.from_user_id
      msg_params["child_messages_attributes"]["0"]["to_user_id"] = receiving_user_id
      msg_params["child_messages_attributes"]["0"]["unread"] = true
      msg_params
    end

    #FIXME_AB: THis is something which I see as repetition. authorize method/callback also find user. So do can you think any other way around. Hint: I don't see any need of this method
    def set_user_from_session
      if session[:user_id]
        @user = User.find(session[:user_id])
      elsif session[:admin_id]
        @user = User.find(session[:admin_id])
      end
    end

end
