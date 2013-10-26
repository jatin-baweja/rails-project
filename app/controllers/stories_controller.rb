class StoriesController < ApplicationController
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
    @stories = Story.all
  end

  def new
    @story = Story.new
  end

  def show
  end

  def edit
  end

  def create
    @story = Story.new(story_params)

    respond_to do |format|
      if @story.save
        format.html { redirect_to story_url(@story),
          notice: "Story #{@story.minimum} was successfully created." }
        format.json { render action: 'show',
          status: :created, location: @story }
      else
        format.html { render action: 'new' }
        format.json { render json: @story.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @story.update(story_params)
        format.html { redirect_to story_url(@story),
          notice: "Story #{@story.minimum} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @story.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      @story.destroy
      flash[:notice] = "Story #{@story.minimum} deleted"
    rescue StandardError => e
      flash[:notice] = e.message
    end
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private

    def set_story
      @story = Story.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def story_params
      params.require(:story).permit(:minimum, :description, :estimated_delivery_on, :shipping, :limit)
    end
end
