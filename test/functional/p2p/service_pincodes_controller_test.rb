require 'test_helper'

class P2p::ServicePincodesControllerTest < ActionController::TestCase
  setup do
    @p2p_service_pincode = p2p_service_pincodes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_service_pincodes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_service_pincode" do
    assert_difference('P2p::ServicePincode.count') do
      post :create, p2p_service_pincode: { pincode: @p2p_service_pincode.pincode }
    end

    assert_redirected_to p2p_service_pincode_path(assigns(:p2p_service_pincode))
  end

  test "should show p2p_service_pincode" do
    get :show, id: @p2p_service_pincode
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_service_pincode
    assert_response :success
  end

  test "should update p2p_service_pincode" do
    put :update, id: @p2p_service_pincode, p2p_service_pincode: { pincode: @p2p_service_pincode.pincode }
    assert_redirected_to p2p_service_pincode_path(assigns(:p2p_service_pincode))
  end

  test "should destroy p2p_service_pincode" do
    assert_difference('P2p::ServicePincode.count', -1) do
      delete :destroy, id: @p2p_service_pincode
    end

    assert_redirected_to p2p_service_pincodes_path
  end
end
