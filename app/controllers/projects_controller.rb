class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy, :back, :pledge, :create_pledge, :description, :backers, :new_message]
  before_action :set_draft_project, only: [:edit, :update, :info, :create_info]
  skip_before_action :authorize, only: [:show, :index, :this_week]
  before_action :validate_owner, only: [:edit, :update, :destroy]
  before_action :check_accessibility, only: [:show]
  before_action :validate_deadline, only: [:show]
  before_action :validate_not_owner, only: [:pledge, :create_pledge]

  def this_week
    @projects = Project.this_week.page(params[:page]).per_page(15)
    render action: :index
  end

  #FIXME_AB: I would prefer URL like: projects/category/mycategory and projects/location/mylocation So we can have it broken in 3 actions?
  def index
    if params[:category]
      @category = Category.find_by(name: params[:category])
      if @category
        @projects = @category.projects.live.order(:title).page(params[:page]).per_page(15)
      end
    elsif params[:place]
      #FIXME_AB: What if params :place or category are blank?
      @projects = Project.live.located_in(params[:place]).order(:title).page(params[:page]).per_page(15)
    else
      @projects = Project.live.order(:title).page(params[:page]).per_page(15)
      #FIXME_AB: You are repeating per_page 15 here
    end
  end

  def new
    @project = Project.new
  end

  def show
    #FIXME_AB: @sum_of_pledges vs @total_pledged_amont
    #FIXME_AB: Also here you are finding out the amount pledged by a user for a project, now can you recall a better way?

    if logged_in?
      @sum_of_pledges = @project.pledges.by_user(current_user).sum(:amount)
    end
  end

  #FIXME_AB: Shuld be accessible by /projects/mine or /projects/owned
  #FIXED: Can be accessed via /my_projects
  def user_owned
    @user_projects = current_user.created_projects.group_by(&:project_state)
  end

  def edit
    @project.edit! if !@project.draft?
  end

  def new_message
    respond_to do |format|
      format.js {}
    end
  end

  def info
  end

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: create_info creates form fields from 3rd step, i.e., the Project model itself
  def create_info
    @project.step = 3
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to rewards_project_url(@project.id) }
        format.json { render action: :show, status: :created, location: @project }
      else
        format.html { render action: :info }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def pledge
  end

  #FIXME_AB: This action can be made better. You improved, but I still see some scope
  def create_pledge
    ActiveRecord::Base.transaction do
      @pledge = @project.pledges.build(pledge_params)
      @pledge.user = current_user
      @pledge.save
      params[:rewards].each do |key, reward|
        @pledge.requested_rewards.create!(reward_id: reward[:id], quantity: reward[:quantity])
        chosen_reward = Reward.find(reward[:id])
        chosen_reward.lock!
        chosen_reward.update(remaining_quantity: (chosen_reward.remaining_quantity - reward[:quantity])) if chosen_reward.remaining_quantity
      end
    end
    if params[:payment_mode] == "Paypal"
      redirect_to @project.paypal_url(project_url(@project), @pledge)
    else
      redirect_to payment_stripe_charges_new_card_url(project: @project.id, pledge: @pledge.id)
    end
  rescue ActiveRecord::RecordInvalid
    render action: :pledge
  end

  def create
    if location_params[:location_name].present?
      if !(@location = Location.find_by(name: location_params[:location_name]))
        @location = Location.new(name: location_params[:location_name])
        @location.save
      end
    end
    @project = @location.projects.build(project_params)
    #FIXME_AB: another way is @project.owner = current_user
    @project.owner_id = current_user.id
    @project.step = 1;

    respond_to do |format|
      if @project.save
        format.html { redirect_to story_project_url(@project.id) }
        format.json { render action: :show, status: :created, location: @project }
      else
        format.html { render action: :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
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
        format.html { render action: :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
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

  def description
    respond_to do |format|
      format.js {}
    end
  end

  def backers
    respond_to do |format|
      format.js {}
    end
  end

  private

  def set_project
    #FIXME_AB: we have a better way to do this
    if !(@project = Project.find_by_permalink(params[:id]))
      if !(@project = Project.find_by(id: params[:id]))
        redirect_to projects_path, alert: 'No such project found'
      end
    end
  end

  def set_draft_project
    if !(@project = Project.find_by(id: params[:id]))
      redirect_to projects_path, alert: 'No such project found'
    end
  end

  def validate_owner
    if(!@project.owner?(current_user))
      redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
    end
  end

  def check_accessibility
    #FIXME_AB: we have a better way to do the same which you have done in the following condition
    if(!@project.approved? && anonymous? && !@project.owner?(current_user) && !current_user.admin?)
      redirect_to projects_path, notice: "Access Denied"
    end
  end

  def validate_deadline
    if(@project.deadline != nil && @project.deadline <= Time.current)
      if !(logged_in? && (@project.owner?(current_user) || current_user.admin?))
        redirect_to projects_path, notice: "Outdated project"
      end
    end
  end


  def blank_rewards?
    reward_present = {}
    if params[:rewards]
      params[:rewards].each do |key, val|
        reward_present[key] = true
        reward_present[key] = false if !val.key?("id")
        val.each do |attr_key, attr_val|
          reward_present[key] = false if attr_val.blank?
        end
      end
      if reward_present.any? { |key, value| value == false }
        render action: :pledge, alert: "Please don't leave empty rewards"
      end
    end
    reward_present.any? { |key, value| value == false }
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:title, :image, :category_id, :summary, :video_url, :duration, :deadline, :goal, :published_at, :location_attributes => [:id, :name], :images_attributes => [:id, :picture])
  end

  def location_params
    params.require(:project).permit(:location_name)
  end

  def pledge_params
    params.require(:pledge).permit(:amount, :requested_rewards_attributes => [:id])
  end

  def validate_not_owner
    if(@project.owner?(current_user))
      redirect_to project_path(@project), notice: "You cannot pledge for your own project"
    end
  end

end
