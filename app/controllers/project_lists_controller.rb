class ProjectListsController < ApplicationController
  #FIXME_AB: I am not sure why we need this controller. I guess everything can be done through projects controller.
  #FIXME_AB: More over I think many of following conditions suits to be defined as scope

  def index
    if params[:category]
      @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title).collect do |x|
        x if x.category.name.downcase == params[:category].downcase
      end
    elsif params[:place]
      @projects = Project.where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).where(project_state: 'approved', location_name: params[:place]).order(:title)
    else
      @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title)
    end
      @projects = Project.search params[:q], :page => params[:page], :per_page => 15
  end

  #FIXME_AB: for search you can have a search controller
  def search
    #FIXME_AB: better to be params[:q].present?
    if !params[:q].blank?
      @projects = Project.search Riddle.escape(params[:q]), :page => params[:page], :per_page => 15, :conditions => { :project_state => 'approved' }, :with => { :deadline => Time.now..1.month.from_now, :published_at => 1.month.ago..Time.now }
    else
      @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title).page(params[:page]).per_page(15)
    end
    render action: 'index'
  end


end
