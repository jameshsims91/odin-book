
require "test_helper"

class DemoUiTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)

    @demo_post = @demo.posts.create!(
      content: "Sample demo post"
    )

    @regular_post = @regular.posts.create!(
      content: "Sample regular post"
    )

    @demo_comment = @demo_post.comments.create!(
      user: @demo,
      content: "Sample demo comment"
    )

    @regular_comment = @regular_post.comments.create!(
      user: @regular,
      content: "Sample regular comment"
    )
  end

  test "demo dashboard hides profile editing and post creation" do
    sign_in @demo

    get authenticated_root_path

    assert_response :success

    assert_select "#new-status-update-form", count: 0

    assert_select "a[href=?]",
                  edit_profile_path(@demo.profile),
                  count: 0
  end

  test "regular dashboard retains profile editing and post creation" do
    sign_in @regular

    get authenticated_root_path

    assert_response :success

    assert_select "#new-status-update-form", count: 1

    assert_select "a[href=?]",
                  edit_profile_path(@regular.profile),
                  count: 1
  end

  test "demo navigation hides account settings but retains logout" do
    sign_in @demo

    get authenticated_root_path

    assert_response :success

    assert_select "a[href=?]",
                  edit_user_registration_path,
                  count: 0

    assert_select "form[action=?]",
                  destroy_user_session_path,
                  minimum: 1
  end

  test "regular navigation retains account settings and logout" do
    sign_in @regular

    get authenticated_root_path

    assert_response :success

    assert_select "a[href=?]",
                  edit_user_registration_path,
                  count: 1

    assert_select "form[action=?]",
                  destroy_user_session_path,
                  minimum: 1
  end

  test "demo post retains content without editing or deletion controls" do
    sign_in @demo

    get post_path(@demo_post)

    assert_response :success

    assert_includes response.body, @demo_post.content

    assert_select "a[href=?]",
                  edit_post_path(@demo_post),
                  count: 0

    assert_select "form[action=?]",
                  post_path(@demo_post),
                  count: 0
  end

  test "regular post retains editing and deletion controls" do
    sign_in @regular

    get post_path(@regular_post)

    assert_response :success

    assert_select "a[href=?]",
                  edit_post_path(@regular_post),
                  count: 1

    assert_select "form[action=?]",
                  post_path(@regular_post),
                  count: 1
  end

  test "demo post retains likes without interaction buttons" do
    sign_in @demo

    get post_path(@demo_post)

    assert_response :success

    assert_select "span[aria-label='Post likes']", count: 1

    assert_select "form[action=?]",
                  post_likes_path(@demo_post),
                  count: 0

    assert_select "form[action=?]",
                  post_like_path(@demo_post, 1),
                  count: 0
  end

  test "regular post retains like button" do
    sign_in @regular

    get post_path(@regular_post)

    assert_response :success

    assert_select "form[action=?]",
                  post_likes_path(@regular_post),
                  count: 1
  end

  test "demo post displays comments without submission form" do
    sign_in @demo

    get post_path(@demo_post)

    assert_response :success

    assert_includes response.body, @demo_comment.content

    assert_select "#comments-list-#{@demo_post.id}",
                  count: 1

    assert_select "#reply-form-#{@demo_post.id}",
                  count: 0

    assert_select "#mentions-wrapper-#{@demo_post.id}",
                  count: 0
  end

  test "regular post retains comment submission form" do
    sign_in @regular

    get post_path(@regular_post)

    assert_response :success

    assert_includes response.body, @regular_comment.content

    assert_select "#reply-form-#{@regular_post.id}",
                  count: 1

    assert_select "#mentions-wrapper-#{@regular_post.id}",
                  count: 1
  end

  test "demo comment retains likes without interaction controls" do
    sign_in @demo

    get post_path(@demo_post)

    assert_response :success

    assert_select "span[aria-label='Comment likes']", count: 1

    assert_select "form[action=?]",
                  post_comment_comment_likes_path(
                    @demo_post, @demo_comment
                  ),
                  count: 0

    assert_select "form[action=?]",
                  post_comment_comment_like_path(
                    @demo_post, @demo_comment, 1
                  ),
                  count: 0

    assert_select "form[action=?]",
                  post_comment_path(@demo_post, @demo_comment),
                  count: 0
  end

  test "regular comment retains like and deletion controls" do
    sign_in @regular

    get post_path(@regular_post)

    assert_response :success

    assert_select "form[action=?]",
                  post_comment_comment_likes_path(
                    @regular_post, @regular_comment
                  ),
                  count: 1

    assert_select "form[action=?]",
                  post_comment_path(
                    @regular_post, @regular_comment
                  ),
                  count: 1
  end
end
