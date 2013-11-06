class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :back, :create_story, :create_rewards, :new_story, :new_rewards]
  skip_before_action :authorize, only: [:show, :index]
  before_action :check_if_user_is_owner, only: [:new, :create, :edit, :update, :new_story, :new_rewards, :create_story, :create_rewards]

  def index
    @projects = Project.where(pending_approval: false).order(:title)
  end

  def new
    @project = Project.new
  end

  def show
    @story = @project.story
    @rewards = @project.rewards
    @user = @project.user
  end

  def user_owned
    @pending_projects = Project.where(owner_id: session[:user_id], pending_approval: true)
    @approved_projects = Project.where(owner_id: session[:user_id], pending_approval: false)
  end

  def edit
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
    project_parameters[:story_attributes][:video].gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
    respond_to do |format|
      if @project.update(project_parameters)
        format.html { redirect_to new_rewards_project_url(@project) }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_rewards
    if @project.rewards.nil?
      @reward = @project.rewards.build
    else
      @reward = @project.rewards
    end
  end

  def create_rewards
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_url(@project),
          notice: "Project #{@project.title} was successfully created." }
        format.json { render action: 'show',
          status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def back
    @project.backers << User.find(session[:user_id])
    respond_to do |format|
      format.js { }
    end
  end

  def create
    @project = Project.new(project_params)
    @project.owner_id = session[:user_id]

    respond_to do |format|
      if @project.save
        format.html { redirect_to new_story_project_url(@project) }
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
    project_parameters[:story_attributes][:video].gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')

    respond_to do |format|
      if @project.update(project_parameters)
        format.html { redirect_to project_url(@project),
          notice: "Project #{@project.title} was successfully updated." }
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

  private

    def set_project
      @project = Project.find(params[:id])
    end


    def check_if_user_is_owner
      if(@project.owner_id != session[:user_id])
        redirect_to project_path(@project), notice: "Only Project Owner can edit this Project"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, :image, :category_id, :blurb, :location_name, :duration, :deadline, :goal, :story_attributes => [:id, :video, :description, :risks], :rewards_attributes => [:id, :minimum, :description, :estimated_delivery_on, :shipping, :limit])
    end

end
