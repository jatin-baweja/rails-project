class SearchesController < ApplicationController
  skip_before_action :authorize
  before_action :search_parameter_available

  def search
    @projects = Project.been_approved.active.search Riddle::Query.escape(params[:q]), :page => params[:page], :per_page => PER_PAGE
    render template: 'projects/index'
  end

  private

    def search_parameter_available
      if params[:q].blank?
        redirect_to root_path
      end
    end
      
end
