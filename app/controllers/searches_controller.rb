class SearchesController < ApplicationController
  skip_before_action :authorize, only: [:search]

  def search
    if params[:q].present?
      @projects = Project.been_approved.active.search Riddle::Query.escape(params[:q]), :page => params[:page], :per_page => 15
    else
      @projects = Project.live.order(:title).page(params[:page]).per_page(15)
    end
    render template: 'projects/index' 
  end

end
