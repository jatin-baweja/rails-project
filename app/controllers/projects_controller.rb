class ProjectsController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:show, :destroy, :backers, :new_message, :edit, :update, :info, :create_info]
  skip_before_action :authorize, only: [:show, :index, :this_week, :category, :location, :backers]
  before_action :validate_owner, only: [:edit, :update, :destroy]
  before_action :check_accessibility, only: [:show]
  before_action :set_location, only: [:create]
  before_action :check_project_state, only: [:edit, :update]

  def this_week
    @projects = Project.includes(:images).live_this_week.page(params[:page]).per_page(PER_PAGE)
    render action: :index
  end

  def index
    @projects = Project.includes(:images).live.order(:title).page(params[:page]).per_page(PER_PAGE)
  end

  def category
    if params[:category].present? && @category = Category.find_by_permalink(params[:category])
      @projects = @category.projects.includes(:images).live.order(:title).page(params[:page]).per_page(PER_PAGE)
    end
    render action: :index
  end

  def location
    if params[:location].present? && @location = Location.find_by_permalink(params[:location])
      @projects = @location.projects.includes(:images).live.order(:title).page(params[:page]).per_page(PER_PAGE)
    end
    render action: :index
  end

  def new
    @project = Project.new
    if @project.images.empty?
      @image = @project.images.build
    else
      @image = @project.images
    end
    if @project.location.nil?
      @location = @project.build_location
    else
      @location = @project.location
    end
  end

  def show
  end

  def user_owned
    @projects = current_user.owned_projects.includes(:images)
  end

  def edit
    if @project.images.empty?
      @image = @project.images.build
    else
      @image = @project.images
    end
    @project.edit! if !@project.draft?
  end

  def new_message
  end

  def info
  end

  def create_info
    if @project.save_info(project_params)
      redirect_to rewards_project_path(@project)
    else
      render action: :info
    end
  end

  def create
    @project = build_project_from_location(@location, project_params)
    if @project.present? && @project.save_primary_details(current_user)
      redirect_to story_project_path(@project)
    else
      @project = Project.new(project_params)
      if @project.invalid?
        render action: :new
      end
    end
  end

  def update
    @project.step = 1
    if @project.update(project_params)
      redirect_to story_project_path(@project)
    else
      render action: :edit
    end
  end

  def destroy
    begin
      @project.destroy
      flash[:notice] = "Project #{@project.title} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    redirect_to root_path
  end

  def new_reward
  end

  def backers
    respond_to do |format|
      format.json { render json: @project.pledges.to_json(:include => { :user => { :only => :name } }, :only => ["amount", "created_at"]) }
    end
  end

  def new_image
  end

  private

  def check_accessibility
    if current_user_owner_or_admin?
      nil
    elsif !@project.approved?
      redirect_to projects_path, notice: "Access Denied"
    elsif @project.outdated?
      redirect_to projects_path, notice: "Outdated project"
    end
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:title, :image, :category_id, :summary, :video_url, :duration, :deadline, :goal, :published_at, :images_attributes => [:id, :attachment], :location_attributes => [:id, :name])
  end

  def validate_not_owner
    if(@project.owner?(current_user))
      redirect_to project_path(@project), notice: "You cannot pledge for your own project"
    end
  end

  def current_user_owner_or_admin?
    logged_in? && (@project.owner?(current_user) || current_user.admin?)
  end

  def set_location
    if project_params[:location_attributes][:name].present?
      @location = Location.find_or_create_by(name: project_params[:location_attributes][:name])
    end
  end

  def build_project_from_location(location, build_params)
    if location.present? && location.persisted?
      @project = location.projects.build(build_params)
    end
  end

  def check_project_state
    unless @project.draft? || @project.submitted?
      redirect_to project_path(@project), notice: 'Project cannot be edited'
    end
  end

end
