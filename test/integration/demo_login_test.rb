
require "test_helper"

class DemoLoginTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @demo = create_account(
      "odin_demo",
      email: "odin_demo@example.invalid",
      demo_account: true
    )

    @regular = create_account("login_regular")
    @other_demo = create_account(
      "login_other_demo",
      demo_account: true
    )
  end

  test "login page displays demo entry button" do
    get new_user_session_path

    assert_response :success

    assert_select "form[action=?][method=post]", demo_login_path do
      assert_select "button", text: "Explore Live Demo"
    end
  end

  test "signed out visitor can enter demo without credentials" do
    post demo_login_path

    assert_response :see_other
    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 1
    assert_select "body", text: /odin_demo/
  end

  test "demo login ignores arbitrary regular user id" do
    post demo_login_path, params: {
      user_id: @regular.id
    }

    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 1
    assert_select "body", text: /odin_demo/
  end

  test "demo login ignores arbitrary demo user id" do
    post demo_login_path, params: {
      user_id: @other_demo.id,
      username: @other_demo.username
    }

    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select "body", text: /odin_demo/
  end

  test "existing regular session is not replaced" do
    sign_in @regular

    post demo_login_path

    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 0
    assert_select "body", text: /login_regular/
  end

  test "existing demo session remains authenticated" do
    sign_in @demo

    post demo_login_path

    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 1
  end

  test "get request cannot authenticate a demo visitor" do
    get demo_login_path

    assert_response :not_found
  end

  test "missing designated demo account fails gracefully" do
    @demo.update_columns(username: "unavailable_demo")

    post demo_login_path

    assert_response :see_other
    assert_redirected_to new_user_session_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 0
  end

  test "regular account cannot be used as designated demo" do
    @demo.update_columns(demo_account: false)

    post demo_login_path

    assert_response :see_other
    assert_redirected_to new_user_session_path
  end

  test "one click demo session cannot create posts" do
    post demo_login_path

    assert_redirected_to authenticated_root_path

    assert_no_difference "Post.count" do
      post posts_path, params: {
        post: {
          content: "Unauthorized demo post"
        }
      }
    end

    assert_redirected_to authenticated_root_path
  end

  test "one click demo session cannot access regular profile" do
    post demo_login_path

    assert_redirected_to authenticated_root_path

    get profile_path(@regular.profile)

    assert_response :not_found
  end

  test "demo visitor can sign out and enter demo again" do
    post demo_login_path

    assert_redirected_to authenticated_root_path

    delete destroy_user_session_path

    assert_response :redirect

    get new_user_session_path

    assert_response :success

    post demo_login_path

    assert_redirected_to authenticated_root_path

    follow_redirect!

    assert_response :success
    assert_select ".demo-banner", count: 1
  end

  private

  def create_account(username, email: nil, demo_account: false)
    User.create!(
      name: username.tr("_", " ").titleize,
      username: username,
      email: email || "#{username}@example.com",
      password: "secure-password-123",
      password_confirmation: "secure-password-123",
      demo_account: demo_account
    )
  end
end
