class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy, :back, :pledge, :create_pledge, :description, :admin_conversation, :create_admin_conversation, :backers, :new_message]
  before_action :set_draft_project, only: [:edit, :update, :create_story, :create_rewards, :new_story, :info, :create_info, :new_rewards]
  skip_before_action :authorize, only: [:show, :index, :this_week]
  before_action :check_if_user_is_owner, only: [:edit, :update, :new_rewards, :create_story, :create_rewards]
  before_action :set_params_for_conversation, only: [:admin_conversation]
  before_action :check_if_user_is_owner_or_admin, only: [:show]
  before_action :check_if_user_is_admin, only: [:create_admin_conversation]
  before_action :check_if_deadline_is_over, only: [:show]

  def this_week
    @projects = Project.approved.published_between(Time.current, Time.current - 1.week).still_active.page(params[:page]).per_page(15)
    render action: 'index'
  end

  #FIXME_AB: I am not sure why we need this controller. I guess everything can be done through projects controller.
  #FIXED: Moved from Project_Lists Controller to Project Controller
  #FIXME_AB: More over I think many of following conditions suits to be defined as scope
  #FIXED: Scopes defined

  def index
    if params[:category]
      @projects = Project.approved.published(Time.current).still_active.order(:title).collect do |x|
        x if x.category.name.downcase == params[:category].downcase
      end
    elsif params[:place]
      @projects = Project.approved.published(Time.current).still_active.located_in(params[:place]).order(:title)
    else
      @projects = Project.approved.published(Time.current).still_active.order(:title).page(params[:page]).per_page(15)
    end
  end

  def new
    @project = Project.new
    @image = @project.images.build
    @location = @project.build_location
  end

  def show
    flash[:notice] = "Your Transaction is #{params[:st]} for amount of $#{params[:amt]}. Thank You for pledging." if params[:st]
    @story = @project.story
    @rewards = @project.rewards
    @user = @project.user
    @sum_of_pledges = Pledge.where([ "user_id = ? AND project_id = ?", session[:user_id], params[:id]]).sum(:amount)
  end

  def user_owned
    @pending_projects = Project.owned_by(current_user).submitted
    @approved_projects = Project.owned_by(current_user).approved
    @draft_projects = Project.owned_by(current_user).draft
    @rejected_projects = Project.owned_by(current_user).rejected
  end

  def edit
    @image = @project.images.first
    @location = @project.location
    @project.edit! if !@project.draft?
  end

  def new_story
    if @project.story.nil?
      @story = @project.build_story
    else
      @story = @project.story
    end
  end

  def create_story
    @project.step = 2;
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to info_project_url(@project.id) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new_story' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_rewards
    if @project.rewards.empty?
      @reward = @project.rewards.build
    else
      @reward = @project.rewards
    end
  end

  def new_message
    @message = @project.messages.build
    respond_to do |format|
      format.js {}
    end
  end

  def create_rewards
    @project.step = 4;
    respond_to do |format|
      if @project.update(project_params)
        @project.submit!
        format.html { redirect_to project_url(@project.id),
          notice: "Project #{@project.title} was successfully created/updated." }
        format.json { render action: 'show',
          status: :created, location: @project }
      else
        format.html { render action: 'new_rewards' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def info
  end

  def create_info
    @project.step = 3
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to rewards_project_url(@project.id) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'info' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def pledge
    @pledge = @project.pledges.build
    @rewards = @project.rewards
    @requested_rewards = @pledge.requested_rewards.build
  end

  def create_pledge
    ActiveRecord::Base.transaction do
      @pledge = @project.pledges.build(pledge_params)
      @pledge.user = current_user
      @pledge.save
      reward_present = false
      if params[:rewards]
        params[:rewards].each do |key, val|
          val.each do |attr_key, attr_val|
            reward_present = true if attr_val.present?
          end
        end
      end
      if reward_present == true
        @rewards = params[:rewards]
        @rewards.each do |key, reward|
          @pledge.requested_rewards.create!(reward_id: reward[:id], quantity: reward[:quantity])
          chosen_reward = Reward.find(reward[:id])
          chosen_reward.update(remaining_quantity: (chosen_reward.remaining_quantity - reward[:quantity])) if chosen_reward.remaining_quantity
        end
      end
    end
    if params[:payment_mode] == "Paypal"
      redirect_to @project.paypal_url(project_url(@project), @pledge)
    else
      redirect_to payment_stripe_charges_new_card_url(project: @project.id, pledge: @pledge.id)
    end
  rescue ActiveRecord::RecordInvalid
    @rewards = @project.rewards
    render action: 'pledge'
  end

  def create
    @project = Project.new(project_params)
    @project.owner_id = session[:user_id]
    @project.step = 1;

    respond_to do |format|
      if @project.save
        format.html { redirect_to story_project_url(@project.id) }
        format.json { render action: 'show',
          status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def update
    @project.step = 1;

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to story_project_url(@project.id) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      @project.destroy
      flash[:notice] = "Project #{@project.title} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def new_reward
    respond_to do |format|
      format.js {}
    end
  end

  def admin_conversation
    @messages = @project.messages.parent_messages.order('updated_at DESC')
    respond_to do |format|
      format.js {}
    end
  end

  def create_admin_conversation
    @messages = @project.messages.order(:created_at)
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

  def description
    @story = @project.story
    @rewards = @project.rewards
    @user = @project.user
    respond_to do |format|
      format.js {}
    end
  end

  def backers
    @pledges = @project.pledges
    respond_to do |format|
      format.js {}
    end
  end

  private

    def set_project
      if !(@project = Project.find_by_permalink(params[:id]))
        @project = Project.find(params[:id])
      end
    end

    def set_draft_project
      @project = Project.find(params[:id])
    end

    def check_if_user_is_owner
      if(logged_in? && @project.owner_id != current_user.id)
        redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
      end
    end

    def check_if_user_is_admin
      if(logged_in? && current_user.admin?)
        redirect_to project_path(@project), notice: "Access Denied"
      end
    end

    def check_if_user_is_owner_or_admin
      if(!@project.approved? && @project.owner_id != current_user.id && !current_user.admin?)
        redirect_to projects_path, notice: "Access Denied"
      end
    end

    def check_if_deadline_is_over
      if(@project.deadline != nil)
        if(@project.owner_id != current_user.id && @project.deadline <= Time.current)
          redirect_to projects_path, notice: "Outdated project"
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :image, :category_id, :summary, :video_url, :duration, :deadline, :goal, :published_at, :location_attributes => [:id, :name], :images_attributes => [:id, :picture], :story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq], :rewards_attributes => [:id, :minimum_amount, :description, :estimated_delivery_on, :shipping, :quantity])
    end

    def conversation_params
      params.require(:message).permit(:id, :subject, :content)
    end

    def pledge_params
      params.require(:pledge).permit(:amount, :requested_rewards_attributes => [:id])
    end

    def set_params_for_conversation
      @user = @project.user
      @messages = @project.messages.order(:created_at)
      @parent_message = @messages.first
      @message = @project.messages.build
    end

end
