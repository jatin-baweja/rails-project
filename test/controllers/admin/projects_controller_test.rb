require 'test_helper'

class Admin::ProjectsControllerTest < ActionController::TestCase
  test "should get pending_for_approval" do
    get :pending_for_approval
    assert_response :success
  end

end
