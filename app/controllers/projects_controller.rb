class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :back, :pledge, :create_pledge, :create_story, :create_rewards, :new_story, :info, :create_info, :new_rewards, :description, :admin_conversation, :create_admin_conversation, :backers, :new_message]
  skip_before_action :authorize, only: [:show, :index, :this_week]
  before_action :check_if_user_is_owner, only: [:edit, :update, :new_rewards, :create_story, :create_rewards]
  before_action :set_params_for_conversation, only: [:admin_conversation]
  before_action :check_if_user_is_owner_or_admin, only: [:show]
  before_action :check_if_user_is_admin, only: [:create_admin_conversation]
  before_action :check_if_deadline_is_over, only: [:show]

  def this_week
    # @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at >= ?) AND (deadline >= ?)', Time.now, Time.now - 1.week, Time.now]).order(:title).page(params[:page]).per_page(15)
    @projects = Project.approved.where(['(published_at <= ? OR published_at >= ?) AND (deadline >= ?)', Time.now, Time.now - 1.week, Time.now]).page(params[:page]).per_page(15)
    render action: 'index'
  end

  def index
    @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title).page(params[:page]).per_page(15)
  end

  def new
    @project = Project.new
    @display_image = @project.display_images.build
  end

  def show
    flash[:notice] = "Your Transaction is #{params[:st]} for amount of $#{params[:amt]}. Thank You for shopping." if params[:st]
    @story = @project.story
    @rewards = @project.rewards
    @user = @project.user
    @sum_of_pledges = Pledge.where([ "user_id = ? AND project_id = ?", session[:user_id], params[:id]]).sum(:amount)
  end

  def user_owned
    @pending_projects = Project.where(owner_id: session[:user_id], project_state: 'submitted')
    @approved_projects = Project.where(owner_id: session[:user_id], project_state: 'approved')
    @editing_projects = Project.where(owner_id: session[:user_id], project_state: 'draft')
    @rejected_projects = Project.where(owner_id: session[:user_id], project_state: 'rejected')
  end

  def edit
    @story = @project.story
    @project.edit! if !@project.draft?
    # if @project.display_images.empty?
      # @display_image = @project.display_images.build
    # else
    #   @display_image = @project.display_images.where(primary: true)[0]
    # end
  end

  def new_story
    if @project.story.nil?
      @story = @project.build_story
    else
      @story = @project.story
    end
  end

  def create_story
    project_parameters = project_params
    @project.step = 2;
    respond_to do |format|
      if @project.update(project_parameters)
        format.html { redirect_to info_project_url(@project) }
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
    project_parameters = project_params
    project_parameters[:deadline] = Time.now + @project.duration.to_i.days
    @project.step = 4;
    respond_to do |format|
      if @project.update(project_parameters)
        @project.submit!
        format.html { redirect_to project_url(@project),
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
        format.html { redirect_to rewards_project_url(@project) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'info' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def back
    @project.backers << User.find(session[:user_id])
    respond_to do |format|
      format.js { }
    end
  end

  def pledge
    @pledge = @project.pledges.build
    @rewards = @project.rewards
    @requested_rewards = @pledge.requested_rewards.build
  end

  def create_pledge
    ActiveRecord::Base.transaction do
      @pledge = Pledge.new(pledge_params_with_user_set)
      @pledge.save
      @rewards = params[:rewards]
      @rewards.each do |key, reward|
        @pledge.requested_rewards.create!(reward_id: reward[:id], quantity: reward[:quantity])
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
    @project = Project.new(project_params_with_youtube_embed_link)
    @project.owner_id = session[:user_id]
    @project.step = 1;

    respond_to do |format|
      if @project.save
        format.html { redirect_to story_project_url(@project) }
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
      if @project.update(project_params_with_youtube_embed_link)
        format.html { redirect_to story_project_url(@project) }
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
    @messages = @project.messages.where('parent_id IS NULL').order('updated_at DESC')
    respond_to do |format|
      format.js {}
    end
  end

  def create_admin_conversation
    @messages = @project.messages.order(:created_at)
    # @parent_message = @messages.where(['subject = ?', conversation_params[:messages_attributes]["0"][:subject]).first
    if session[:user_id] != @project.owner_id && session[:admin_id]
      conv_params = altered_conversation_params(session[:admin_id], @project.owner_id)
      @from = User.find(session[:admin_id])
      @to = User.find(@project.owner_id)
    end
    @message = conv_params[:messages_attributes]["0"][:content]
    if @project.update(conv_params)
      MessageNotifier.sent(@to, @from, @project, @message).deliver
      redirect_to admin_conversation_project_url
    end
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
      @project = Project.find(params[:id])
    end

    def check_if_user_is_owner
      if(@project.owner_id != session[:user_id])
        redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
      end
    end

    def check_if_user_is_admin
      if(!session[:admin_id])
        redirect_to project_path(@project), notice: "Access Denied"
      end
    end

    def check_if_user_is_owner_or_admin
      if(!@project.approved? && @project.owner_id != session[:user_id] && !session[:admin_id])
        redirect_to projects_path, notice: "Access Denied"
      end
    end

    def check_if_deadline_is_over
      if(@project.deadline != nil)
        if(@project.owner_id != session[:user_id] && @project.deadline <= Time.now.utc)
          redirect_to projects_path, notice: "Outdated project"
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :image, :category_id, :summary, :location_name, :video_url, :duration, :deadline, :goal, :published_at, :display_images_attributes => [:id, :picture], :story_attributes => [:id, :description, :risks, :why_we_need_help, :about_the_team, :faq], :rewards_attributes => [:id, :minimum_amount, :description, :estimated_delivery_on, :shipping, :quantity])
    end

    def project_params_with_youtube_embed_link
      project_parameters = project_params
      project_parameters[:video_url].gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
      project_parameters
    end


    def conversation_params
      params.require(:project).permit(:messages_attributes => [:id, :subject, :content])
    end

    def altered_conversation_params(from_id, to_id)
      conv_params = conversation_params
      conv_params[:messages_attributes]["0"][:from_user_id] = from_id;
      conv_params[:messages_attributes]["0"][:to_user_id] = to_id;
      conv_params
    end


    def pledge_params
      params.require(:project).permit(:pledges_attributes => [:id, :amount, :requested_rewards_attributes => [:id] ])
    end

    def pledge_params_with_user_set
      altered_pledge_params = pledge_params
      altered_pledge_params[:pledges_attributes]["0"][:user_id] = session[:user_id]
      altered_pledge_params[:pledges_attributes]["0"][:project_id] = @project.id
      altered_pledge_params[:pledges_attributes]["0"]
    end

    def set_params_for_conversation
      @user = @project.user
      @messages = @project.messages.order(:created_at)
      @parent_message = @messages.first
      @message = @project.messages.build
    end

end
