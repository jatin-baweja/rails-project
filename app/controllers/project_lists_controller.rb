class ProjectListsController < ApplicationController

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

  def search
    if !params[:q].blank?
      @projects = Project.search Riddle.escape(params[:q]), :page => params[:page], :per_page => 15, :conditions => { :project_state => 'approved' }, :with => { :deadline => Time.now..1.month.from_now, :published_at => 1.month.ago..Time.now }
    else
      @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title).page(params[:page]).per_page(15)
    end
    render action: 'index'
  end


end
