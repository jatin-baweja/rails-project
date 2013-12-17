class SearchesController < ApplicationController
  skip_before_action :authorize, only: [:search]

  def search
    if params[:q].present?
      #FIXME_AB: Lots of scope of improvement in following line. Please do as per your learning after CR comments
      #FIXED: Using sphinx_scopes and changed Time.now to Time.current
      @projects = Project.approved.active.search Riddle::Query.escape(params[:q]), :page => params[:page], :per_page => 15
    else
      #FIXME_AB: I have suggested a new scope :live in some other place. we can use that here too
      #FIXED: Using live
      @projects = Project.live.order(:title).page(params[:page]).per_page(15)
    end
    render template: 'projects/index' 
  end

end
