require 'spec_helper'

describe Admin::MessagesController do

  describe "GET 'index'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
    end

    it "assigns @project" do
      get :index, format: :json
      assigns[:project].should_not be_nil
    end

    it "assigns @messages" do
      get :index, format: :json
      assigns[:messages].should_not be_nil
    end

    it "returns http success" do
      get :index, format: :json
      response.should be_success
    end

  end

  describe "POST 'create'" do

    let(:message_params) { FactoryGirl.attributes_for(:message) }
    let(:incorrect_message_params) { FactoryGirl.attributes_for(:message, content: "", subject: "") }

    before(:each) do
      @user = FactoryGirl.create(:admin)
      User.stub(:find_by).and_return(@user)
      controller.stub(:current_user).and_return(@user)
      @project = FactoryGirl.create(:project_with_messages)
      Project.stub(:find_by_permalink).and_return(@project)
    end

    it "assigns @project" do
      post :create, id: @project, message: message_params, format: :js
      assigns[:project].should_not be_nil
    end

    it "assigns @messages" do
      post :create, id: @project, message: message_params, format: :js
      assigns[:messages].should_not be_nil
    end

    context "when valid attributes" do

      it "returns http success" do
        post :create, id: @project, message: message_params, format: :js
        response.should be_success
      end

    end

    context "when invalid attributes" do

      it "returns http success" do
        post :create, id: @project, message: incorrect_message_params, format: :js
        response.body.should == "alert('The message could not be sent.');"
      end

    end

  end

end
