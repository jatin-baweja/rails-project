require 'spec_helper'

describe RewardsController do

  let(:project) { mock_model(Project).as_null_object }

  before(:each) do
    controller.stub(:authorize).and_return(true)
    controller.stub(:validate_owner).and_return(true)
    Project.stub(:find_by_permalink).and_return(project)
  end

  describe "GET 'new'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
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

  describe "PATCH 'create'" do

    before(:each) do
      @project = FactoryGirl.create(:project)
      Project.stub(:find_by_permalink).and_return(@project)
    end
  
    it "assigns @project" do
      patch :create, id: @project, project: FactoryGirl.attributes_for(:project, title: 'Updated Project')
      assigns[:project].should_not be_nil
    end

    context "when valid attributes" do

      it "redirects to project page" do
        patch :create, id: @project, project: FactoryGirl.attributes_for(:project, title: 'Updated Project')
        response.should redirect_to(project_path(@project))
      end

    end

  end

end
