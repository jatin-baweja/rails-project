class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :back, :pledge, :create_pledge, :create_story, :create_rewards, :new_story, :info, :create_info, :new_rewards, :description, :admin_conversation, :create_admin_conversation, :backers]
  skip_before_action :authorize, only: [:show, :index]
  before_action :check_if_user_is_owner, only: [:edit, :update, :new_rewards, :create_story, :create_rewards]
  before_action :set_params_for_conversation, only: [:admin_conversation]
  before_action :check_if_user_is_owner_or_admin, only: [:show]
  before_action :check_if_deadline_is_over, only: [:show]

  def index
    @projects = Project.where(pending_approval: false).where(['(publish_on <= ? OR publish_on IS NULL) AND (deadline >= ? OR deadline IS NULL)', Time.now, Time.now]).order(:title)
  end

  def new
    @project = Project.new
    @story = @project.build_story
  end

  def show
    @story = @project.story
    @rewards = @project.rewards
    @user = @project.user
    @pledge = Pledge.find(:first, :conditions => [ "user_id = ? AND project_id = ?", session[:user_id], params[:id]])
  end

  def user_owned
    @pending_projects = Project.where(owner_id: session[:user_id], pending_approval: true, editing: false, rejected: false)
    @approved_projects = Project.where(owner_id: session[:user_id], pending_approval: false, editing: false, rejected: false)
    @editing_projects = Project.where(owner_id: session[:user_id], editing: true, rejected: false)
    @rejected_projects = Project.where(owner_id: session[:user_id], rejected: true)
  end

  def edit
    @story = @project.story
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
    # project_parameters[:story_attributes][:video].gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
    respond_to do |format|
      if @project.update(project_parameters)
        format.html { redirect_to info_project_url(@project) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
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

  def create_rewards
    project_parameters = project_params
    project_parameters[:editing] = 'false'
    project_parameters[:deadline] = Time.now + @project.duration.to_i.days
    respond_to do |format|
      if @project.update(project_parameters)
        format.html { redirect_to project_url(@project),
          notice: "Project #{@project.title} was successfully created/updated." }
        format.json { render action: 'show',
          status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def info
  end

  def create_info
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to rewards_project_url(@project) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
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
  end

  def create_pledge
    pledged_params = pledge_params
    pledged_params[:pledges_attributes]["0"][:user_id] = session[:user_id]
    @project.update(pledged_params)
    @amount = pledged_params[:pledges_attributes]["0"][:amount]
    redirect_to project_url(@project), notice: "You have pledged $#{@amount} for #{@project.title}"
  end

  def create
    project_parameters = project_params
    project_parameters[:story_attributes][:video].gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
    @project = Project.new(project_parameters)
    @project.owner_id = session[:user_id]
    @project.editing = true;

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
    project_parameters = project_params

    respond_to do |format|
      if @project.update(project_parameters)
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
    respond_to do |format|
      format.js {}
    end
  end

  def create_admin_conversation
    conv_params = conversation_params
    if session[:user_id] != @project.owner_id
      conv_params[:project_conversations_attributes]["0"][:converser_id] = session[:admin_id];
      conv_params[:project_conversations_attributes]["0"][:converser_type] = 'admin';
      conv_params[:project_conversations_attributes]["0"][:messages_attributes]["0"][:from_converser] = 'true';
      @admin = Admin.find(session[:admin_id])
      @user = User.find(@project.owner_id)
      @message = conv_params[:project_conversations_attributes]["0"][:messages_attributes]["0"][:content]
      MessageNotifier.sent(@user, @admin, @project, @message).deliver
    else
      conv_params[:project_conversations_attributes]["0"][:converser_id] = Admin.first.id;
      conv_params[:project_conversations_attributes]["0"][:converser_type] = 'admin';
      conv_params[:project_conversations_attributes]["0"][:messages_attributes]["0"][:from_converser] = 'false';
      @admin = Admin.first
      @user = User.find(@project.owner_id)
      @message = conv_params[:project_conversations_attributes]["0"][:messages_attributes]["0"][:content]
      MessageNotifier.sent(@admin, @user, @project, @message).deliver
    end
    Rails.logger.debug "\n\n\n\n\n\n\n#{ conv_params }\n\n\n\n\n\n\n"
    @project.update(conv_params)
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
    @backers = @project.pledges
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

    def check_if_user_is_owner_or_admin
      if(@project.pending_approval? && @project.owner_id != session[:user_id] && !session[:admin_id])
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
      params.require(:project).permit(:title, :image, :category_id, :summary, :location_name, :duration, :deadline, :goal, :publish_on, :story_attributes => [:id, :video, :description, :risks, :why_we_need_help, :about_the_team, :faq], :rewards_attributes => [:id, :minimum, :description, :estimated_delivery_on, :shipping, :limit])
    end

    def conversation_params
      params.require(:project).permit(:project_conversations_attributes => [:id, :messages_attributes => [:id, :content] ])
    end

    def pledge_params
      params.require(:project).permit(:pledges_attributes => [:id, :amount, :requested_rewards_attributes => [:id] ])
    end

    def set_params_for_conversation
      @user = @project.user
      @conversation = @project.project_conversations.where(converser_type: 'admin')[0]
      if !@conversation.nil?
        @messages = @conversation.messages.order(:created_at)
      else
        @conversation = @project.project_conversations.build
      end
      @message = @conversation.messages.build
    end


end
