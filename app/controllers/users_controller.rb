class UsersController < ApplicationController
  cache_sweeper :user_sweeper, only: [:update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :user_is_current_user, only: [:edit, :update, :destroy]
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
          #FIXED: Changed user on-create message
          notice: "Dear #{@user.name}, you have been successfully registered." }
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
      #FIXED: Put user check before edit, update and destroy
      if @user.update(user_params)
        format.html { redirect_to user_url(@user),
          #FIXME_AB: message not appropriate
          #FIXED: Message changed
          notice: "Your profile has been successfully updated." }
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
      #FIXED: Put user check before edit, update and destroy
      @user.destroy
      flash[:notice] = "Your account has been deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  #FIXME_AB: Shouldn't we create a separate controller to import contacts
  #FIXED: Created contacts controller

  #FIXME_AB: why messaging is being done in users controller. I think we need to have a controller for messaging?
  #FIXED: Added messages controller

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_is_current_user
      if !logged_in? || current_user.id != @user.id
        redirect_to root_url, notice: 'Access Denied'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end

    #FIXME_AB: THis is something which I see as repetition. authorize method/callback also find user. So do can you think any other way around. Hint: I don't see any need of this method
    #FIXED: using current_user method in messages controller

end
