require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should create a like" do
    @post = posts(:two)

    assert_difference("Like.count", 1) do
      post post_likes_path(@post)
    end

    assert_redirected_to posts_path
    assert @user.likes.exists?(post: @post)
  end

  test "should destroy a like" do
    @post = posts(:one)
    @like = likes(:one)

    assert_difference("Like.count", -1) do
      delete post_like_path(@post, @like)
    end

    assert_redirected_to posts_path
    assert_not @user.likes.exists?(post: @post)
  end
end
