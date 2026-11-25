
require "test_helper"

class DemoInteractionSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)
    @demo_post = posts(:one)

    sign_in @regular
  end

  test "regular user cannot like demo post through direct request" do
    assert_no_difference("Like.count") do
      post post_likes_path(@demo_post)
    end

    assert_response :not_found
  end

  test "regular user cannot comment on demo post through direct request" do
    assert_no_difference("Comment.count") do
      post post_comments_path(@demo_post), params: {
        comment: { content: "Unauthorized comment" }
      }
    end

    assert_response :not_found
  end

  test "regular user cannot send demo user a friend request" do
    assert_no_difference("Friendship.count") do
      post friendships_path, params: {
        friend_id: @demo.id
      }
    end

    assert_response :not_found
  end

  test "regular user cannot like demo comment through direct request" do
    comment = Comment.create!(
      user: @demo,
      post: @demo_post,
      content: "Protected demo comment"
    )

    assert_no_difference("CommentLike.count") do
      post post_comment_comment_likes_path(@demo_post, comment)
    end

    assert_response :not_found
  end

  test "regular user cannot like a comment using an unrelated post URL" do
    first_post = @regular.posts.create!(content: "First post")
    second_post = @regular.posts.create!(content: "Second post")

    comment = first_post.comments.create!(
      user: @regular,
      content: "Example comment"
    )

    assert_no_difference("CommentLike.count") do
      post post_comment_comment_likes_path(second_post, comment)
    end

    assert_response :not_found
  end

  test "regular user can still comment on regular post" do
    regular_post = posts(:two)

    assert_difference("Comment.count", 1) do
      post post_comments_path(regular_post), params: {
        comment: { content: "Allowed comment" }
      }
    end

    assert_response :redirect
  end
end
