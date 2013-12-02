class Admin::UsersController < Admin::SessionsController
  cache_sweeper :user_sweeper, only: [:destroy]
  before_action :set_user, only: [:destroy, :make_admin]
  before_action :admin_authorize

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
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :no_content }
    end
  end

  def make_admin
    begin
      @user.admin = true
      @user.save!
      flash[:notice] = "User #{@user.name} promoted to admin status"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :no_content }
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

end
