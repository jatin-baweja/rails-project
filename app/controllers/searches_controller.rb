class SearchesController < ApplicationController

  #FIXME_AB: for search you can have a search controller
  #FIXED: Moved to search controller
  def search
    #FIXME_AB: better to be params[:q].present?
    #FIXED: Changed to present
    if params[:q].present?
      @projects = Project.search Riddle.escape(params[:q]), :page => params[:page], :per_page => 15, :conditions => { :project_state => 'approved' }, :with => { :deadline => Time.now..1.month.from_now, :published_at => 1.month.ago..Time.now }
    else
      @projects = Project.approved.published(Time.current).still_active.order(:title).page(params[:page]).per_page(15)
    end
    render template: 'projects/index' 
  end

end
