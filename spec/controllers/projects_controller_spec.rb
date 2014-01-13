require 'spec_helper'

describe ProjectsController do

  before(:each) do
    controller.stub(:authorize).and_return(true)
    controller.stub(:check_accessibility).and_return(true)
    controller.stub(:validate_owner).and_return(true)
  end

  describe "GET 'index'" do

    it "assigns @projects" do
      get :index
      assigns[:projects].should_not be_nil
    end

    it "renders index template" do
      get :index
      expect(response).to render_template("index")
    end

  end

  describe "GET 'this_week'" do

    it "assigns @projects" do
      get :this_week
      assigns[:projects].should_not be_nil
    end

    it "renders index template" do
      get :this_week
      expect(response).to render_template("index")
    end

  end

  describe "GET 'new'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:new).and_return(project)
    end

    it "assigns @project" do
      get :new
      assigns[:project].should_not be_nil
    end

    it "renders new template" do
      get :new
      expect(response).to render_template("new")
    end
  end

  describe "GET 'show'" do

    before do
      @project = FactoryGirl.create(:project_with_pledges)
      Project.stub(:find_by_permalink).and_return(@project)
    end

    it "assigns @project" do
      get :show
      assigns[:project].should_not be_nil
    end

    context "when logged in" do

      before :each do
        @user = FactoryGirl.create(:user)
        User.stub(:find_by).and_return(@user)
        controller.stub(:current_user).and_return(@user)
      end

      it "assigns @total_pledged_amount" do
        get :show
        assigns[:total_pledged_amount].should_not be_nil
      end

    end

    it "renders show template" do
      get :show
      expect(response).to render_template("show")
    end

  end

  describe "GET 'category'" do

    context "when category exists" do

      before :each do
        @user = FactoryGirl.create(:user)
        User.stub(:find_by).and_return(@user)
        controller.stub(:current_user).and_return(@user)
        @category = FactoryGirl.create(:category_with_projects)
        Category.stub(:find_by_permalink).and_return(@category)
      end

      it "assigns @category" do
        get :category, category: @category.name
        assigns[:category].should_not be_nil
      end

      it "assigns @projects" do
        get :category, category: @category.name
        assigns[:projects].should_not be_nil
      end

    end

    it "renders index template" do
      get :category
      expect(response).to render_template("index")
    end

  end

  describe "GET 'location'" do

    context "when location exists" do

      before :each do
        @user = FactoryGirl.create(:user)
        User.stub(:find_by).and_return(@user)
        controller.stub(:current_user).and_return(@user)
        @location = FactoryGirl.create(:location_with_projects)
        Location.stub(:find_by_permalink).and_return(@location)
      end

      it "assigns @location" do
        get :location, location: @location.name
        assigns[:location].should_not be_nil
      end

      it "assigns @projects" do
        get :location, location: @location.name
        assigns[:projects].should_not be_nil
      end

    end

    it "renders index template" do
      get :location
      expect(response).to render_template("index")
    end

  end

  describe "GET 'user_owned'" do

    let (:user) { mock_model(User).as_null_object }

    before(:each) do
      controller.stub(:current_user).and_return(user)
    end

    it "assigns @projects" do
      get :user_owned
      assigns[:projects].should_not be_nil
    end

    it "renders user_owned template" do
      get :user_owned
      expect(response).to render_template("user_owned")
    end

  end

  describe "GET 'edit'" do

    let(:project) { mock_model(Project, project_state: 'submitted').as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
    end

    it "assigns @project" do
      get :edit
      assigns[:project].should_not be_nil
    end

    context "when project in submitted state" do

      let(:draft_project) { mock_model(Project, project_state: 'draft').as_null_object }

      before(:each) do
        project.stub(:edit!).and_return(draft_project)
      end

      it "moves project to draft state" do
        get :edit
        project.edit!.should eq(draft_project)
      end

    end

    it "renders edit template" do
      get :edit
      expect(response).to render_template("edit")
    end

  end

  describe "GET 'new_message'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
    end

    it "assigns @project" do
      get :new_message, format: :js
      assigns[:project].should_not be_nil
    end

    it "renders new_message template" do
      get :new_message, format: :js
      expect(response).to render_template("new_message")
    end

  end

  describe "GET 'info'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
      Project.stub(:find).and_return(project)
    end

    it "assigns @project" do
      get :info
      assigns[:project].should_not be_nil
    end

    it "renders info template" do
      get :info
      expect(response).to render_template("info")
    end

  end

  describe "PATCH 'create_info'" do

    let(:publish_at) { Time.current + 2.days }

    let(:info_params) { { :duration => "24", :published_at => publish_at, :goal => "2000" } }

    let(:incorrect_info_params) { { :duration => "35", :published_at => publish_at, :goal => "abc" } }

    before(:each) do
      @project = FactoryGirl.create(:project)
      Project.stub(:find_by_permalink).and_return(@project)
    end
  
    it "assigns @project" do
      patch :create_info, id: @project, project: info_params
      assigns[:project].should_not be_nil
    end

    context "when valid attributes" do

      it "updates duration" do
        expect {
          patch :create_info, id: @project, project: info_params
        }.to change { @project.duration }.to(24)
      end

      it "updates funding goal" do
        expect {
          patch :create_info, id: @project, project: info_params
        }.to change { @project.goal }.to(2000)
      end

      it "redirects to project page" do
        patch :create_info, id: @project, project: info_params
        response.should redirect_to(rewards_project_path(@project))
      end

    end

    # # Should work but is not working
    # context "when invalid attributes" do

    #   it "renders info template" do
    #     patch :create_info, id: @project, project: info_params
    #     puts response.body
    #     expect(response).to render_template("info")
    #   end

    # end

  end


  # describe "POST 'create'" do

  #   let(:proj_params) { { :title => 'Sample Title', summary: 'Sample Words', location_name: 'Lucknow', video_url: 'http://www.youtube.com/watch?v=12er34_fe', :pledges_attributes => { "0" => FactoryGirl.attributes_for(:pledge) } } }

  #   before :each do
  #     # @project = FactoryGirl.create(:project)
  #     # Project.stub(:find_by_permalink).and_return(@project)
  #     # Project.stub(:find).and_return(@project)
  #   end

  #   it "creates a new project" do
  #     expect {
  #       post :create, project: proj_params
  #     }.to change(Project, :count).by(1)
  #   end

  #   # context "when payment mode is Paypal" do
  #   #   it "redirects to Paypal Payment Page" do
  #   #     post :create_pledge, project: pledge_params, id: @project.id
  #   #     response.should redirect_to @project.paypal_url(project_url(@project), Pledge.last)
  #   #   end
  #   # end

  #   context "when valid attributes" do
  #     it "redirects to Project Story Page" do
  #       post :create, project: proj_params
  #       response.should redirect_to story_project_url(Project.last.id)
  #     end
  #   end

  # end

  describe "PATCH 'update'" do

    before(:each) do
      @project = FactoryGirl.create(:project)
      Project.stub(:find_by_permalink).and_return(@project)
      Project.stub(:find).and_return(@project)
    end

    it "assigns @project" do
      patch :update, id: @project, project: FactoryGirl.attributes_for(:project, title: 'Updated Project')
      assigns[:project].should_not be_nil
    end

    context "when valid attributes" do

      it "updates @project" do
        expect {
          patch :update, id: @project, project: FactoryGirl.attributes_for(:project, title: 'Updated Project')
        }.to change { @project.title }.to('Updated Project')
      end

      it "redirects to story page" do
        patch :update, id: @project, project: FactoryGirl.attributes_for(:project, title: 'Updated Project')
        response.should redirect_to(story_project_path(@project))
      end

    end

    context "when invalid attributes" do

      it "renders edit template" do
        patch :update, id: @project, project: FactoryGirl.attributes_for(:project, title: '')
        expect(response).to render_template("edit")
      end

    end

  end

  describe 'DELETE destroy' do

    before :each do
      @project = FactoryGirl.create(:project)
      Project.stub(:find_by_permalink).and_return(@project)
    end

    context "when possible to destroy" do

      it "deletes the project" do
        expect {
          delete :destroy, id: @project
        }.to change(@project, :deleted_at).from(nil)
      end

      it "sets flash message" do
        delete :destroy, id: @project
        flash[:notice].should_not be_nil
      end

    end

    context "when unable to destroy" do

      before :each do
        @project.stub(:destroy).and_raise(StandardError)
      end

      it "sets flash message to standard error" do
        delete :destroy, id: @project
        flash[:notice].should == "StandardError"
      end

    end

    it "redirects to root" do
      delete :destroy, id: @project
      response.should redirect_to root_url
    end

  end

  describe "GET 'new_reward'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
      Project.stub(:find).and_return(project)
    end

    it "renders new_reward template" do
      get :new_reward, format: :js
      expect(response).to render_template("new_reward")
    end

  end

  describe "GET 'backers'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
      @user = FactoryGirl.create(:user)
      @pledge = FactoryGirl.create(:pledge, project_id: project.id, user_id: @user)
    end

    it "assigns @project" do
      get :backers, format: :json
      assigns[:project].should_not be_nil
    end

    it "return http success" do
      get :backers, format: :json
      expect(response).to be_success
    end

  end

end
