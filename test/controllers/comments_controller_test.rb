require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:two)

    sign_in @user
  end

  test "should create a comment" do
    assert_difference("Comment.count", 1) do
      post post_comments_path(@post), params: {
        comment: {
          content: "This is a test comment."
        }
      }
    end

    assert_redirected_to post_path(@post)

    assert @post.comments.exists?(
      user: @user,
      content: "This is a test comment."
    )
  end
end
