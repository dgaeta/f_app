require 'test_helper'

class DecidedlocationsControllerTest < ActionController::TestCase
  setup do
    @decidedlocation = decidedlocations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:decidedlocations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create decidedlocation" do
    assert_difference('Decidedlocation.count') do
      post :create, decidedlocation: { decision: @decidedlocation.decision, geo_lat: @decidedlocation.geo_lat, geo_long: @decidedlocation.geo_long, gym_name: @decidedlocation.gym_name }
    end

    assert_redirected_to decidedlocation_path(assigns(:decidedlocation))
  end

  test "should show decidedlocation" do
    get :show, id: @decidedlocation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @decidedlocation
    assert_response :success
  end

  test "should update decidedlocation" do
    put :update, id: @decidedlocation, decidedlocation: { decision: @decidedlocation.decision, geo_lat: @decidedlocation.geo_lat, geo_long: @decidedlocation.geo_long, gym_name: @decidedlocation.gym_name }
    assert_redirected_to decidedlocation_path(assigns(:decidedlocation))
  end

  test "should destroy decidedlocation" do
    assert_difference('Decidedlocation.count', -1) do
      delete :destroy, id: @decidedlocation
    end

    assert_redirected_to decidedlocations_path
  end
end
