require 'test_helper'

class P2p::CreditsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

  test "should get list" do
    get :list
    assert_response :success
  end

end
