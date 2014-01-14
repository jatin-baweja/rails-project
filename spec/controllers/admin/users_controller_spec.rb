require 'spec_helper'

describe Admin::UsersController do

  before(:each) do
    controller.stub(:admin_authorize).and_return(true)
  end

  describe "GET 'index'" do

    it "assigns @users" do
      get :index
      assigns[:users].should_not be_nil
    end

    it "renders index template" do
      get :index
      expect(response).to render_template(:index)
    end

  end

  describe 'DELETE destroy' do

    context "when valid user" do

      before :each do
        @user = FactoryGirl.create(:user)
        User.stub(:find_by).and_return(@user)
      end

      context "when possible to destroy" do

        it "deletes the user" do
          expect {
            delete :destroy, id: @user
          }.to change(@user, :deleted_at).from(nil)
        end

        it "sets flash message" do
          delete :destroy, id: @user
          flash[:notice].should_not be_nil
        end

      end

      context "when unable to destroy" do

        before :each do
          @user.stub(:destroy).and_raise(StandardError)
        end

        it "sets flash message to standard error" do
          delete :destroy, id: @user
          flash[:notice].should == "StandardError"
        end

      end

      it "redirects to users index page" do
        delete :destroy, id: @user
        response.should redirect_to admin_users_path
      end

    end

    context "when invalid user" do

      before :each do
        User.stub(:find_by).and_return(false)
      end

      it "redirects to users index page" do
        delete :destroy
        response.should redirect_to admin_users_path
      end

      it "sets flash message" do
        delete :destroy
        flash[:notice].should == "Invalid user id"
      end

    end

  end

  describe 'GET make_admin' do

    before :each do
      @user = FactoryGirl.create(:user)
      User.stub(:find_by).and_return(@user)
    end

    context "when converted to admin" do

      it "updates admin to true" do
        expect {
          get :make_admin, id: @user
        }.to change(@user, :admin).to(true)
      end

      it "sets flash message" do
        get :make_admin, id: @user
        flash[:notice].should_not be_nil
      end

    end

    context "when unable to convert to admin" do

      before :each do
        @user.stub(:save).and_return(false)
      end

      it "sets flash message" do
        get :make_admin, id: @user
        flash[:alert].should_not be_nil
      end

    end

    it "redirects to users index page" do
      get :make_admin, id: @user
      response.should redirect_to admin_users_path
    end

  end

end
