class SearchesController < ApplicationController

  def search
    if params[:q].present?
      #FIXME_AB: Lots of scope of improvement in following line. Please do as per your learning after CR comments
      @projects = Project.search Riddle.escape(params[:q]), :page => params[:page], :per_page => 15, :conditions => { :project_state => 'approved' }, :with => { :deadline => Time.now..1.month.from_now, :published_at => 1.month.ago..Time.now }
    else
      #FIXME_AB: I have suggested a new scope :live in some other place. we can use that here too
      @projects = Project.approved.published(Time.current).still_active.order(:title).page(params[:page]).per_page(15)
    end
    render template: 'projects/index' 
  end

end
