
require "test_helper"

class PostRenderingSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)

    sign_in @regular
  end

  test "post content escapes injected script tags" do
    post_record = @regular.posts.create!(
      content: "<script>alert('unsafe')</script>"
    )

    get post_path(post_record)

    assert_response :success
    assert_select "script", text: "alert('unsafe')", count: 0
    assert_includes response.body, "&lt;script&gt;"
  end

  test "regular post does not link to demo mention" do
    post_record = @regular.posts.create!(
      content: "Hello @#{@demo.username}"
    )

    get post_path(post_record)

    assert_response :success

    assert_select "a[href=?]",
                  user_path(@demo),
                  count: 0
  end

  test "regular post can link to regular mention" do
    mentioned_user = User.create!(
      name: "Charlie Smith",
      username: "charlie",
      email: "charlie@example.com",
      password: "secure-password-123",
      password_confirmation: "secure-password-123"
    )

    post_record = @regular.posts.create!(
      content: "Hello @#{mentioned_user.username}"
    )

    get post_path(post_record)

    assert_response :success

    assert_not_nil mentioned_user.profile

    assert_select "a[href=?]",
                  profile_path(mentioned_user.profile),
                  text: "@#{mentioned_user.username}",
                  count: 1
  end

  test "cross-account comment is not displayed" do
    post_record = posts(:two)

    comment = Comment.new(
      user: @demo,
      post: post_record,
      content: "Hidden cross-account comment"
    )

    comment.save!(validate: false)

    get post_path(post_record)

    assert_response :success
    assert_not_includes response.body,
                        "Hidden cross-account comment"
  end

  test "cross-account friend is not returned" do
    friendship = Friendship.find_or_initialize_by(
      user: @regular,
      friend: @demo
    )

    friendship.status = "accepted"
    friendship.save!(validate: false)

    assert_not_includes @regular.reload.friends, @demo
  end
end
