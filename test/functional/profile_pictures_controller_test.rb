require 'test_helper'

class ProfilePicturesControllerTest < ActionController::TestCase
  setup do
    @profile_picture = profile_pictures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profile_pictures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profile_picture" do
    assert_difference('ProfilePicture.count') do
      post :create, profile_picture: { user_id: @profile_picture.user_id }
    end

    assert_redirected_to profile_picture_path(assigns(:profile_picture))
  end

  test "should show profile_picture" do
    get :show, id: @profile_picture
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profile_picture
    assert_response :success
  end

  test "should update profile_picture" do
    put :update, id: @profile_picture, profile_picture: { user_id: @profile_picture.user_id }
    assert_redirected_to profile_picture_path(assigns(:profile_picture))
  end

  test "should destroy profile_picture" do
    assert_difference('ProfilePicture.count', -1) do
      delete :destroy, id: @profile_picture
    end

    assert_redirected_to profile_pictures_path
  end
end
