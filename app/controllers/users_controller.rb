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

  #FIXME_AB: Can I destroy my own account. I think this should not allowed. Do not allow to destroy for now
  #FIXED: Removed destroy method

  private

    def set_user
      unless (@user = User.find_by(id: params[:id]))
        redirect_to root_path, alert: 'No such user found'
      end
    end

    def verify_owner
      if anonymous? || current_user.id != @user.id
        redirect_to root_url, notice: 'Access Denied'
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end


end
