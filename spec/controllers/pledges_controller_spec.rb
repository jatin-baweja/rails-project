require 'spec_helper'

describe PledgesController do

  let(:project) { mock_model(Project).as_null_object }

  before(:each) do
    controller.stub(:authorize).and_return(true)
    controller.stub(:validate_not_owner).and_return(true)
    controller.stub(:check_blank_rewards).and_return(true)
    Project.stub(:find_by_permalink).and_return(project)
  end

  describe "GET 'new'" do

    let(:project) { mock_model(Project).as_null_object }

    before do
      Project.stub(:find_by_permalink).and_return(project)
    end

    it "renders pledge template" do
      get :new
      expect(response).to render_template("new")
    end

  end

  describe "POST 'create'" do

    let(:pledge_params) { FactoryGirl.attributes_for(:pledge_with_requested_rewards) }

    before :each do
      @project = FactoryGirl.create(:project)
      Project.stub(:find_by_permalink).and_return(@project)
    end

    it "creates a new pledge" do
      expect {
        post :create, pledge: pledge_params
      }.to change(Pledge, :count).by(1)
    end

    context "when payment mode is Paypal" do
      it "redirects to Paypal Payment Page" do
        post :create, pledge: pledge_params, payment_mode: "Paypal"
        response.should redirect_to Paypal.url(@project, project_url(@project), Pledge.last)
      end
    end

    context "when payment mode is Credit Card" do
      it "redirects to the Stripe Payment Page" do
        post :create, pledge: pledge_params, payment_mode: "Stripe"
        response.should redirect_to payment_stripe_charges_new_card_url(project: @project.id, pledge: Pledge.last.id)
      end
    end

  end

end
