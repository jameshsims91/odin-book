
require "test_helper"

class ProfileNavigationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @regular = create_account("navigation_regular")
    @regular_friend = create_account("navigation_friend")

    @demo = create_account(
      "navigation_demo",
      demo_account: true
    )

    @demo_friend = create_account(
      "navigation_demo_friend",
      demo_account: true
    )
  end

  test "regular user is redirected to associated profile" do
    sign_in @regular

    get user_path(@regular_friend)

    assert_redirected_to profile_path(@regular_friend.profile)

    follow_redirect!

    assert_response :success
  end

  test "demo user is redirected to associated demo profile" do
    sign_in @demo

    get user_path(@demo_friend)

    assert_redirected_to profile_path(@demo_friend.profile)

    follow_redirect!

    assert_response :success
  end

  test "own legacy user path redirects to sanctuary" do
    sign_in @regular

    get user_path(@regular)

    assert_redirected_to authenticated_root_path
  end

  test "regular user cannot access legacy demo user path" do
    sign_in @regular

    get user_path(@demo)

    assert_response :not_found
  end

  test "demo user cannot access legacy regular user path" do
    sign_in @demo

    get user_path(@regular)

    assert_response :not_found
  end

  test "regular user cannot access demo profile directly" do
    sign_in @regular

    get profile_path(@demo.profile)

    assert_response :not_found
  end

  test "demo user cannot access regular profile directly" do
    sign_in @demo

    get profile_path(@regular.profile)

    assert_response :not_found
  end

  test "signed out visitor cannot access legacy user path" do
    get user_path(@regular)

    assert_response :not_found
  end

  private

  def create_account(username, demo_account: false)
    User.create!(
      name: username.tr("_", " ").titleize,
      username: username,
      email: "#{username}@example.com",
      password: "secure-password-123",
      password_confirmation: "secure-password-123",
      demo_account: demo_account
    )
  end
end
