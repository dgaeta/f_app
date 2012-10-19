require 'test_helper'

class GameMembersControllerTest < ActionController::TestCase
  setup do
    @game_member = game_members(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_members)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_member" do
    assert_difference('GameMember.count') do
      post :create, game_member: { checkins: @game_member.checkins, checkouts: @game_member.checkouts, game_id: @game_member.game_id, successful_checks: @game_member.successful_checks, user_id: @game_member.user_id }
    end

    assert_redirected_to game_member_path(assigns(:game_member))
  end

  test "should show game_member" do
    get :show, id: @game_member
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_member
    assert_response :success
  end

  test "should update game_member" do
    put :update, id: @game_member, game_member: { checkins: @game_member.checkins, checkouts: @game_member.checkouts, game_id: @game_member.game_id, successful_checks: @game_member.successful_checks, user_id: @game_member.user_id }
    assert_redirected_to game_member_path(assigns(:game_member))
  end

  test "should destroy game_member" do
    assert_difference('GameMember.count', -1) do
      delete :destroy, id: @game_member
    end

    assert_redirected_to game_members_path
  end
end
