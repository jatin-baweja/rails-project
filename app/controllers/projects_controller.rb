class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy, :back, :pledge, :create_pledge, :description, :backers, :new_message]
  before_action :set_draft_project, only: [:edit, :update, :info, :create_info]
  skip_before_action :authorize, only: [:show, :index, :this_week]
  #FIXME_AB: Validate_owner?
  #FIXED: Changed method name
  before_action :validate_owner, only: [:edit, :update, :destroy]
  #FIXME_AB: check_if_user_is_owner_or_admin is not just checking user or admin. It is also checking the state of user. So it should name it :check_accessibility. Similarly for others
  #FIXED: Method names changed
  before_action :check_accessibility, only: [:show]


  before_action :validate_deadline, only: [:show]

  def this_week
    #FIXME_AB: This is taking projects in past on week. Not this week Mon-Sat.
    #FIXME_AB: Much of this can be moved to model
    #FIXED: Moved to project model as scope
    #FIXME_AB: Time.current called twice can be saved
    #FIXED: Using 1.week.ago
    @projects = Project.this_week.page(params[:page]).per_page(15)
    render action: 'index'
  end

  #FIXME_AB: I would prefer URL like: projects/category/mycategory and projects/location/mylocation So we can have it broken in 3 actions?
  #FIXED: URL is presently in this format
  def index
    if params[:category]
      @category = Category.find_by(name: params[:category])
      if @category
      #FIXME_AB: Project.live I added a comment for this scope somewhere
      #FIXED: Added scope live to project model
        @projects = @category.projects.live.order(:title).page(params[:page]).per_page(15)
        #FIXME_AB: What you are doing is, loading all projects and then filtering them based on the category name. Very BAD
        #FIXME_AB: YOu should use the project-category association to load such projects. Also use pagination. Current implementation is very inefficient 
        #FIXED: changed implementation
      end
    elsif params[:place]
      #FIXME_AB: pagination
      #FIXED: Added pagination
      @projects = Project.live.located_in(params[:place]).order(:title).page(params[:page]).per_page(15)
    else
      @projects = Project.live.order(:title).page(params[:page]).per_page(15)
    end
  end

  def new
    @project = Project.new
  end

  def show
    #FIXME_AB: I have to look what is params[:st]. But setting flash this way is not the right way
    #FIXED: Removed it.
    #FIXME_AB: Why you are creating instance variables for story, rewards, users. You don't need them here. And for views you have @project variable available. So use can use @project.story and others in the view directly
    #FIXED: Moved variables to view
    @sum_of_pledges = Pledge.where([ "user_id = ? AND project_id = ?", session[:user_id], params[:id]]).sum(:amount)
  end

  #FIXME_AB: Shuld be accessible by /projects/mine or /projects/owned
  #FIXED: Can be accessed via /my_projects
  def user_owned
    #FIXME_AB: I have another way to do this in a single query.
    #FIXED: Used group_by
    @user_projects = current_user.created_projects.group_by(&:project_state)
  end

  def edit
    #FIXME_AB: You just need @project variable other @image and @location is not needed here. You are preparing for the view. You would be having @project variable available in view so you can use that directly
    #FIXED: Moved to view
    @project.edit! if !@project.draft?
  end

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved new_story to stories controller

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved create_story to stories controller

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved new_rewards to rewards controller

  def new_message
    respond_to do |format|
      format.js {}
    end
  end

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved create_rewards to rewards controller

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: The info includes form fields from 3rd step, i.e., the Project model itself
  def info
  end

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: create_info creates form fields from 3rd step, i.e., the Project model itself
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
  end

  #FIXME_AB: This action can be made better
  #FIXED: Improved code
  def create_pledge
    if !blank_rewards?
      ActiveRecord::Base.transaction do
        @pledge = @project.pledges.build(pledge_params)
        @pledge.user = current_user
        @pledge.save
        params[:rewards].each do |key, reward|
          if reward_present[key]
            @pledge.requested_rewards.create!(reward_id: reward[:id], quantity: reward[:quantity])
            chosen_reward = Reward.find(reward[:id])
            chosen_reward.lock!
            chosen_reward.update(remaining_quantity: (chosen_reward.remaining_quantity - reward[:quantity])) if chosen_reward.remaining_quantity
          end
        end
      end
      if params[:payment_mode] == "Paypal"
        redirect_to @project.paypal_url(project_url(@project), @pledge)
      else
        redirect_to payment_stripe_charges_new_card_url(project: @project.id, pledge: @pledge.id)
      end
    else
      @rewards = @project.rewards
      render action: :pledge, alert: "Please don't leave empty rewards"
    end
  rescue ActiveRecord::RecordInvalid
    @rewards = @project.rewards
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
    #FIXME_AB: Why referring to session user_id
    #FIXED: Changed to current_user
    @project.owner_id = current_user.id
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
      #FIXME_AB: Any project can be destroyed
      #FIXED: Added before_action validate_owner to destroy action
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

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved admin_conversation to messages controller

  #FIXME_AB: I am not yet very convinced why we need this in this controller
  #FIXED: Moved create_admin_conversation to messages controller

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
      if(@project.owner_id != current_user.id)
        redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
      end
    end

    def check_accessibility
      if(!@project.approved? && @project.owner_id != current_user.id && !current_user.admin?)
        redirect_to projects_path, notice: "Access Denied"
      end
    end

    def validate_deadline
      if(@project.deadline != nil)
        if(@project.owner_id != current_user.id && @project.deadline <= Time.current)
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

end
