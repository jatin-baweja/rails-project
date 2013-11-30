class RewardsController < ApplicationController
  before_action :set_reward, only: [:show, :edit, :update, :destroy]
  before_action :set_project, only: [:choose]

  def index
    @rewards = Reward.all
  end

  def new
    @reward = Reward.new
  end

  def choose
    @rewards = @project.rewards
  end

  def chosen
    @rewards_ids = params[:rewards]
  end

  def show
  end

  def edit
  end

  def create
    @reward = Reward.new(reward_params)

    respond_to do |format|
      if @reward.save
        format.html { redirect_to reward_url(@reward),
          notice: "Reward #{@reward.minimum_amount} was successfully created." }
        format.json { render action: 'show',
          status: :created, location: @reward }
      else
        format.html { render action: 'new' }
        format.json { render json: @reward.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @reward.update(reward_params)
        format.html { redirect_to reward_url(@reward),
          notice: "Reward #{@reward.minimum_amount} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @reward.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      @reward.destroy
      flash[:notice] = "Reward #{@reward.minimum_amount} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def set_reward
      @reward = Reward.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reward_params
      params.require(:reward).permit(:minimum_amount, :description, :estimated_delivery_on, :quantity)
    end

end
