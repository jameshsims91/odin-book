require "test_helper"
class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_post = posts(:two)

    sign_in @user
  end

  test "cannot update another user's post" do
    original_content = @other_post.content

    patch post_path(@other_post), params: {
      post: {
        content: "Unauthorized modification"
      }
    }

    assert_response :not_found

    assert_equal original_content,
                 @other_post.reload.content
  end

  test "cannot delete another user's post" do
    assert_no_difference("Post.count") do
      delete post_path(@other_post)
    end

    assert_response :not_found
  end
end
