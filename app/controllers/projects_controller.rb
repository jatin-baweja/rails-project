class ProjectsController < ApplicationController

  def index
    @projects = User.order(:title)
  end

  def new
    @project = Project.new
    @story = @project.build_story
    @reward = @project.rewards.build
  end

  def show
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

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

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :email, :email_confirmation, :password, :password_confirmation)
    end

end
