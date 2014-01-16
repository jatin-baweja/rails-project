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
    if @user.save
      redirect_to login_path(@user), notice: "Dear #{@user.name}, you have been successfully registered. Please log in to continue"
    else
      render action: :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Your profile has been successfully updated."
    else
      render action: :edit
    end
  end


  private

    def set_user
      unless (@user = User.find_by(id: params[:id]))
        redirect_to root_path, alert: 'No such user found'
      end
    end

    def verify_owner
      if anonymous? || current_user.id != @user.id
        redirect_to root_path, notice: 'Access Denied'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end


end
