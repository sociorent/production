require 'test_helper'

class P2p::CitiesControllerTest < ActionController::TestCase
  setup do
    @p2p_city = p2p_cities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_cities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_city" do
    assert_difference('P2p::City.count') do
      post :create, p2p_city: {  }
    end

    assert_redirected_to p2p_city_path(assigns(:p2p_city))
  end

  test "should show p2p_city" do
    get :show, id: @p2p_city
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_city
    assert_response :success
  end

  test "should update p2p_city" do
    put :update, id: @p2p_city, p2p_city: {  }
    assert_redirected_to p2p_city_path(assigns(:p2p_city))
  end

  test "should destroy p2p_city" do
    assert_difference('P2p::City.count', -1) do
      delete :destroy, id: @p2p_city
    end

    assert_redirected_to p2p_cities_path
  end
end
