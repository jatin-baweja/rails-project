class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :back]
  skip_before_action :authorize, only: [:show, :index]
  before_action :check_if_user_is_owner, only: [:edit, :update]

  def index
    @projects = Project.order(:title)
  end

  def new
    @project = Project.new
    @story = @project.build_story
    @reward = @project.rewards.build
  end

  def show
    @story = @project.story
    @reward = @project.rewards.take
    @user = @project.user
  end

  def edit
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

  def update
    respond_to do |format|
      if @project.update(project_params)
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
      params.require(:project).permit(:title, :image, :category_id, :blurb, :location_name, :duration, :deadline, :goal, :story_attributes => [ :video, :description, :risks], :rewards_attributes => [:minimum, :estimated_delivery_on, :shipping, :limit])
    end

end
