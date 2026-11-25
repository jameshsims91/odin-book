
require "test_helper"

class DemoVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular_user = users(:two)
    @regular_post = posts(:two)
    @regular_profile = @regular_user.profile

    sign_in @demo
  end

  test "demo account cannot view regular user directly" do
    get user_path(@regular_user)

    assert_response :not_found
  end

  test "demo account cannot view regular user post directly" do
    get post_path(@regular_post)

    assert_response :not_found
  end

  test "demo account cannot view regular user profile directly" do
    get "/profiles/#{@regular_profile.id}"

    assert_response :not_found
  end

  test "demo account can view its own post" do
    get post_path(posts(:one))

    assert_response :success
  end

  test "demo account cannot find regular users in directory" do
    get users_path, params: {
      query: @regular_user.username
    }

    assert_response :success
    assert_select "a[href=?]", user_path(@regular_user), count: 0
    assert_select "p",
                  text: "No profiles found matching your criteria."
  end

  test "regular account can still view its own posts" do
    sign_out @demo
    sign_in @regular_user

    get post_path(@regular_post)

    assert_response :success
  end

  test "demo account cannot search for regular friends" do
    friendship = Friendship.find_or_initialize_by(
      user: @demo,
      friend: @regular_user
    )

    friendship.status = "accepted"
    friendship.save!(validate: false)

    get search_users_path, params: {
      q: @regular_user.username
    }, as: :json

    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "regular account cannot view demo post directly" do
    sign_out @demo
    sign_in @regular_user

    get post_path(posts(:one))

    assert_response :not_found
  end
end
