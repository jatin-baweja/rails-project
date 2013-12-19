class UsersController < ApplicationController
  cache_sweeper :user_sweeper, only: [:update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :verify_owner, only: [:edit, :update, :destroy]
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
        #FIXED: Using single line
        format.html { redirect_to user_url(@user), notice: "Dear #{@user.name}, you have been successfully registered." }
        format.json { render action: :show, status: :created, location: @user }
      else
        format.html { render action: :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "Your profile has been successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  #FIXME_AB: Can I destroy my own account. I think this should not allowed
  #FIXED: You should have the option to delete your account from the website
  def destroy
    begin
      @user.destroy
      reset_session
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
      if !(@user = User.find_by(id: params[:id]))
        redirect_to root_path, alert: 'No such user found'
      end
      #FIXME_AB: Waht if user not found with this id
      #FIXED: Changed find to find_by
    end

    #FIXME_AB: Method name verify_owner, suits better
    #FIXED: Changed method name to verify_owner
    def verify_owner
      #FIXME_AB: !logged_in? => anonymous?
      #FIXED: Changed !logged_in? to anonymous?
      if anonymous? || current_user.id != @user.id
        redirect_to root_url, notice: 'Access Denied'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end


end
