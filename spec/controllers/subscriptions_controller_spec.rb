require 'spec_helper'

describe SubscriptionsController do

  describe "GET 'new'" do

    it "assigns @subscriber" do
      get :new
      assigns[:subscriber].should_not be_nil
    end

    it "returns http success" do
      get :new
      response.should be_success
    end

  end

  describe "POST 'create'" do

    before :each do
      @subscriber = FactoryGirl.build(:subscriber)
    end

    it "assigns @subscriber" do
      post :create, subscriber: FactoryGirl.attributes_for(:subscriber)
      assigns[:subscriber].should_not be_nil
    end

    context "with valid attributes" do

      before :each do
        @subscriber.stub(:valid?).and_return(true)
      end

      it "sets flash message" do
        post :create, subscriber: FactoryGirl.attributes_for(:subscriber)
        flash[:notice].should_not be_nil
      end

      it "redirects to root path" do
        post :create, subscriber: FactoryGirl.attributes_for(:subscriber)
        expect(response).to redirect_to(root_path)
      end

    end

    context "with invalid attributes" do

      before :each do
        @subscriber.stub(:valid?).and_return(false)
      end

      # # Not working as expected
      # it "renders new template" do
      #   post :create, subscriber: FactoryGirl.attributes_for(:subscriber)
      #   expect(response).to render_template(:new)
      # end

    end

  end

end
