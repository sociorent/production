require 'test_helper'

class P2p::ItemDeliveriesControllerTest < ActionController::TestCase
  setup do
    @p2p_item_delivery = p2p_item_deliveries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_item_deliveries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_item_delivery" do
    assert_difference('P2p::ItemDelivery.count') do
      post :create, p2p_item_delivery: {  }
    end

    assert_redirected_to p2p_item_delivery_path(assigns(:p2p_item_delivery))
  end

  test "should show p2p_item_delivery" do
    get :show, id: @p2p_item_delivery
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_item_delivery
    assert_response :success
  end

  test "should update p2p_item_delivery" do
    put :update, id: @p2p_item_delivery, p2p_item_delivery: {  }
    assert_redirected_to p2p_item_delivery_path(assigns(:p2p_item_delivery))
  end

  test "should destroy p2p_item_delivery" do
    assert_difference('P2p::ItemDelivery.count', -1) do
      delete :destroy, id: @p2p_item_delivery
    end

    assert_redirected_to p2p_item_deliveries_path
  end
end
