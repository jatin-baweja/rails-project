require 'spec_helper'

describe MessagesController do

  let(:project) { mock_model(Project).as_null_object }

  before(:each) do
    controller.stub(:authorize).and_return(true)
    @user = FactoryGirl.create(:user)
    User.stub(:find_by).and_return(@user)
  end

  describe "GET 'index'" do

    it "assigns @messages" do
      get :index
      assigns[:messages].should_not be_nil
    end

    it "renders index template" do
      get :index
      expect(response).to render_template("index")
    end

  end

  describe "GET 'show'" do

    context "when message exists" do

      before :each do
        @message = FactoryGirl.create(:message)
        @message_group = FactoryGirl.create_list(:message, 5, parent_id: nil)
        Message.stub(:parent_messages).and_return(@message_group)
        @message_group.stub(:find_by).and_return(@message)
        @message.stub(:last_receiver?).with(@user).and_return(true)
      end

      it "assigns @reply_message" do
        get :show
        assigns[:reply_message].should_not be_nil
      end

      it "renders show template" do
        get :show
        expect(response).to render_template("show")
      end

    end

    context "when message does not exist" do

      it "redirects to index page" do
        get :show
        expect(response).to redirect_to messages_path
      end

    end

  end

  describe "POST 'create'" do

    let(:message_params) { FactoryGirl.attributes_for(:message) }

    before :each do
      @message = FactoryGirl.create(:message)
      @message_group = FactoryGirl.create_list(:message, 5, parent_id: nil)
      Message.stub(:parent_messages).and_return(@message_group)
      @message_group.stub(:find_by).and_return(@message)
    end

    it "assigns @reply_message" do
      post :create, message: message_params
      assigns[:reply_message].should_not be_nil
    end

    context "when reply message is successfully created" do

      it "redirects to message page" do
        post :create, message: message_params
        response.should redirect_to message_path(@message)
      end

    end

    context "when message cannot be created" do

      it "renders show page" do
        post :create, message: { content: "" }
        response.should render_template :show
      end

    end

  end

end
