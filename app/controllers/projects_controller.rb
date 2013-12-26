class ProjectsController < ApplicationController
  include Projects::Callbacks

  before_action :set_project, only: [:show, :destroy, :description, :backers, :new_message, :edit, :update, :info, :create_info]
  skip_before_action :authorize, only: [:show, :index, :this_week]
  before_action :validate_owner, only: [:edit, :update, :destroy]
  before_action :check_accessibility, only: [:show]

  def this_week
    @projects = Project.this_week.page(params[:page]).per_page(DEFAULT_PER_PAGE_RESULT_COUNT)
    render action: :index
  end

  def index
    @projects = Project.live.order(:title).page(params[:page]).per_page(DEFAULT_PER_PAGE_RESULT_COUNT)
  end

  def category
    #FIXME_AB: Is the category name unique? I think we should use permalink for category too, as we are using it in url
    #FIXED: Category permalink added
    if params[:category].present? && @category = Category.find_by_permalink(params[:category])
      @projects = @category.projects.live.order(:title).page(params[:page]).per_page(DEFAULT_PER_PAGE_RESULT_COUNT)
    end
    render action: :index
  end

  def location
    if params[:location].present? && @location = Location.find_by_permalink(params[:location])
      #FIXME_AB: should we also use permalink for location?
      #FIXED: Added permalink for location
      @projects = @location.projects.live.order(:title).page(params[:page]).per_page(DEFAULT_PER_PAGE_RESULT_COUNT)
    end
    render action: :index
  end

  def new
    @project = Project.new
  end

  def show
    #FIXME_AB: Also here you are finding out the amount pledged by a user for a project, now can you recall a better way?
    if logged_in?
      @total_pledged_amount = current_user.pledge_amount_for_project(@project)
    end
  end

  def user_owned
    @user_projects = current_user.owned_projects.group_by(&:project_state)
  end

  def edit
    #FIXME_AB: Lets give this action a thought.
    @project.edit! if !@project.draft?
    redirect_path = case @project.step
    when 1 then story_project_url(@project)
    when 2 then info_project_url(@project)
    when 3 then rewards_project_url(@project)
    else nil
    end
    if redirect_path
      redirect_to redirect_path
    end
  end

  def new_message
    respond_to do |format|
      format.js {}
    end
  end

  def info
  end

  def create_info
    respond_to do |format|
      if @project.save_info(project_params)
        format.html { redirect_to rewards_project_url(@project) }
        format.json { render action: :show, status: :created, location: @project }
      else
        format.html { render action: :info }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end



  def create
    #FIXME_AB: Lets revisit this action
    if location_params[:location_name].present?
      if @location = Location.find_or_create_by(name: location_params[:location_name])
        @project = @location.projects.build(project_params)

        respond_to do |format|
          if @project.save_primary_details(current_user)
            format.html { redirect_to story_project_url(@project) }
            format.json { render action: :show, status: :created, location: @project }
          else
            format.html { render action: :new }
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  def update
    @project.step = 1;

    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to story_project_url(@project) }
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
  end

  def backers
    respond_to do |format|
      format.json { render json: @project.pledges.to_json(:include => { :user => { :only => :name } }, :only => ["amount", "created_at"]) }
    end
  end

  private


  def check_accessibility
    #FIXME_AB: Using unless with too many conditions
    #FIXED: Merged check_accessibility and validate_deadline
    if (logged_in? && (@project.owner?(current_user) || current_user.admin?))
      continue
    elsif !@project.approved?
      redirect_to projects_path, notice: "Access Denied"
    elsif @project.deadline == nil || @project.deadline <= Time.current
      redirect_to projects_path, notice: "Outdated project"
    end
  end

    #FIXME_AB: Something is wrong here too.
    #FIXED: Combined check_accessibility and validate_deadline

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:title, :image, :category_id, :summary, :video_url, :duration, :deadline, :goal, :published_at, :location_attributes => [:id, :name], :images_attributes => [:id, :picture])
  end

  def location_params
    params.require(:project).permit(:location_name)
  end

  def validate_not_owner
    if(@project.owner?(current_user))
      redirect_to project_path(@project), notice: "You cannot pledge for your own project"
    end
  end

end
