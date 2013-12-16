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
        #FIXME_AB: When you have multiple lines. use do-end block instead of {}
        format.html { redirect_to user_url(@user),
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
      if @user.update(user_params)
        format.html { redirect_to user_url(@user),
          notice: "Your profile has been successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors,
          status: :unprocessable_entity }
      end
    end
  end

  #FIXME_AB: Can I destroy my own account. I think this should not allowed
  def destroy
    begin
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

  private

    def set_user
      @user = User.find(params[:id])
      #FIXME_AB: What if user not found with this id
    end

    #FIXME_AB: Method name verify_owner, suits better
    def user_is_current_user
      #FIXME_AB: !logged_in? => anonymous?
      if !logged_in? || current_user.id != @user.id
        redirect_to root_url, notice: 'Access Denied'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end


end
