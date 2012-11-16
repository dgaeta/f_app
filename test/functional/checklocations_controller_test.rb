require 'test_helper'

class ChecklocationsControllerTest < ActionController::TestCase
  setup do
    @checklocation = checklocations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:checklocations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create checklocation" do
    assert_difference('Checklocation.count') do
      post :create, checklocation: { geo_lat: @checklocation.geo_lat, geo_long: @checklocation.geo_long, gym_name: @checklocation.gym_name, requester_id: @checklocation.requester_id }
    end

    assert_redirected_to checklocation_path(assigns(:checklocation))
  end

  test "should show checklocation" do
    get :show, id: @checklocation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @checklocation
    assert_response :success
  end

  test "should update checklocation" do
    put :update, id: @checklocation, checklocation: { geo_lat: @checklocation.geo_lat, geo_long: @checklocation.geo_long, gym_name: @checklocation.gym_name, requester_id: @checklocation.requester_id }
    assert_redirected_to checklocation_path(assigns(:checklocation))
  end

  test "should destroy checklocation" do
    assert_difference('Checklocation.count', -1) do
      delete :destroy, id: @checklocation
    end

    assert_redirected_to checklocations_path
  end
end
