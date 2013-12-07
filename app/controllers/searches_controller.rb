class SearchesController < ApplicationController

  #FIXME_AB: for search you can have a search controller
  #FIXED: Moved to search controller
  def search
    #FIXME_AB: better to be params[:q].present?
    #FIXED: Changed to present
    if params[:q].present?
      @projects = Project.search Riddle.escape(params[:q]), :page => params[:page], :per_page => 15, :conditions => { :project_state => 'approved' }, :with => { :deadline => Time.now..1.month.from_now, :published_at => 1.month.ago..Time.now }
    else
      @projects = Project.where(project_state: 'approved').where(['(published_at <= ? OR published_at IS NULL) AND (deadline >= ?)', Time.now, Time.now]).order(:title).page(params[:page]).per_page(15)
    end
    render template: 'projects/index' 
  end

end
