class ProjectListsController < ApplicationController

  def index
    if params[:category]
      @projects = Project.where(pending_approval: false).order(:title).collect do |x|
        x if x.category.name.downcase == params[:category].downcase
      end
    # elsif params[:tag]
    #   @projects = Project.where(pending_approval: false).order(:title)
    elsif params[:place]
      @projects = Project.where(pending_approval: false, location_name: params[:place]).order(:title)
    else
      @projects = Project.where(pending_approval: false).order(:title)
    end
  end

end
