require 'spec_helper'

describe Payment::Stripe::ChargesController do

  before(:each) do
    controller.stub(:authorize).and_return(true)
  end

  describe "GET 'new_card'" do

    before(:each) do
      @project = FactoryGirl.create(:project)
      @user = FactoryGirl.create(:user)
      @pledge = FactoryGirl.create(:pledge)
      Project.stub(:find_by).and_return(@project)
      Pledge.stub(:find_by).and_return(@pledge)
      controller.stub(:current_user).and_return(@user)
    end

    it "assigns @project" do
      get :new_card
      assigns[:project].should_not be_nil
    end

    it "assigns @pledge" do
      get :new_card
      assigns[:pledge].should_not be_nil
    end

    it "assigns @user" do
      get :new_card
      assigns[:user].should_not be_nil
    end

    it "renders new_card template" do
      get :new_card
      expect(response).to render_template("new_card")
    end

  end

  describe "POST 'create_card'" do

    let (:card_params) { { :card_number => "4242424242424242", :expiry_date => {"(2i)" => Time.current.month, "(1i)" => Time.current.year + 2 }, :cvc_number => '555', :name_on_card => Faker::Name.name } }

    before(:each) do
      @project = FactoryGirl.create(:project)
      @user = FactoryGirl.create(:user)
      @pledge = FactoryGirl.create(:pledge)
      controller.stub(:current_user).and_return(@user)
      Pledge.stub(:find_by).and_return(@pledge)
      @pledge.stub(:project).and_return(@project)
      @pledge.stub(:user).and_return(@user)
    end

    it "adds a transaction" do
      expect {
        post :create_card, card_params
      }.to change(Transaction, :count).by(1)
    end

    it "redirect to project path" do
      post :create_card, card_params
      expect(response).to redirect_to project_path(@project)
    end

  end

end
