require 'test_helper'

class P2p::ProductsControllerTest < ActionController::TestCase
  setup do
    @p2p_product = p2p_products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_product" do
    assert_difference('P2p::Product.count') do
      post :create, p2p_product: { name: @p2p_product.name, priority: @p2p_product.priority }
    end

    assert_redirected_to p2p_product_path(assigns(:p2p_product))
  end

  test "should show p2p_product" do
    get :show, id: @p2p_product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_product
    assert_response :success
  end

  test "should update p2p_product" do
    put :update, id: @p2p_product, p2p_product: { name: @p2p_product.name, priority: @p2p_product.priority }
    assert_redirected_to p2p_product_path(assigns(:p2p_product))
  end

  test "should destroy p2p_product" do
    assert_difference('P2p::Product.count', -1) do
      delete :destroy, id: @p2p_product
    end

    assert_redirected_to p2p_products_path
  end
end
