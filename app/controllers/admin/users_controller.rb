class Admin::UsersController < Admin::BaseController
  # cache_sweeper :user_sweeper, only: [:destroy]
  before_action :set_user, only: [:destroy, :make_admin]
  before_action :valid_user, only: [:destroy]

  def index
    @users = User.page(params[:page]).per_page(20)
  end

  def destroy
    begin
      @user.destroy
      flash[:notice] = "User #{@user.name} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    redirect_to admin_users_path
  end

  def make_admin
    @user.admin = true
    if @user.save
      flash[:notice] = "User #{@user.name} promoted to admin status"
    else
      flash[:alert] = "User #{@user.name} could not be promoted to admin status"
    end
    redirect_to admin_users_path
  end

  private

    def set_user
      unless (@user = User.find_by(id: params[:id]))
        redirect_to admin_users_path, notice: 'Invalid user id'
      end
    end

    def valid_user
      if @user.id == current_user.id
        redirect_to admin_users_path, notice: 'Not allowed to delete your own account'
      end
    end

end
