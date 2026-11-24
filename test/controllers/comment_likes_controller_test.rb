require "test_helper"

class CommentLikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should create a comment like" do
    @comment = comments(:two)

    assert_difference("CommentLike.count", 1) do
      post post_comment_comment_likes_path(
        @comment.post, @comment
      )
    end

    assert_redirected_to authenticated_root_path
    assert @user.comment_likes.exists?(comment: @comment)
  end

  test "should destroy a comment like" do
    @comment = comments(:one)
    @like = comment_likes(:one)

    assert_difference("CommentLike.count", -1) do
      delete post_comment_comment_like_path(
        @comment.post, @comment, @like
      )
    end

    assert_redirected_to authenticated_root_path
    assert_not @user.comment_likes.exists?(comment: @comment)
  end
end
