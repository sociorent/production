require 'test_helper'

class P2p::CategoriesControllerTest < ActionController::TestCase
  setup do
    @p2p_category = p2p_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_category" do
    assert_difference('P2p::Category.count') do
      post :create, p2p_category: {  }
    end

    assert_redirected_to p2p_category_path(assigns(:p2p_category))
  end

  test "should show p2p_category" do
    get :show, id: @p2p_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_category
    assert_response :success
  end

  test "should update p2p_category" do
    put :update, id: @p2p_category, p2p_category: {  }
    assert_redirected_to p2p_category_path(assigns(:p2p_category))
  end

  test "should destroy p2p_category" do
    assert_difference('P2p::Category.count', -1) do
      delete :destroy, id: @p2p_category
    end

    assert_redirected_to p2p_categories_path
  end
end
