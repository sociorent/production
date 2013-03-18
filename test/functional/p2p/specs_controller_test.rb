require 'test_helper'

class P2p::SpecsControllerTest < ActionController::TestCase
  setup do
    @p2p_spec = p2p_specs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:p2p_specs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create p2p_spec" do
    assert_difference('P2p::Spec.count') do
      post :create, p2p_spec: { name: @p2p_spec.name, priority: @p2p_spec.priority }
    end

    assert_redirected_to p2p_spec_path(assigns(:p2p_spec))
  end

  test "should show p2p_spec" do
    get :show, id: @p2p_spec
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @p2p_spec
    assert_response :success
  end

  test "should update p2p_spec" do
    put :update, id: @p2p_spec, p2p_spec: { name: @p2p_spec.name, priority: @p2p_spec.priority }
    assert_redirected_to p2p_spec_path(assigns(:p2p_spec))
  end

  test "should destroy p2p_spec" do
    assert_difference('P2p::Spec.count', -1) do
      delete :destroy, id: @p2p_spec
    end

    assert_redirected_to p2p_specs_path
  end
end
