
require "test_helper"

class DemoAccountSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)
    sign_in @demo
  end

  test "demo account cannot create posts" do
    assert_no_difference("Post.count") do
      post posts_path, params: {
        post: { content: "Unauthorized demo post" }
      }
    end

    assert_response :see_other
  end

  test "demo account cannot update posts" do
    post_record = @demo.posts.create!(content: "Original content")

    patch post_path(post_record), params: {
      post: { content: "Modified content" }
    }

    assert_response :see_other
    assert_equal "Original content", post_record.reload.content
  end

  test "demo account cannot delete posts" do
    post_record = @demo.posts.create!(content: "Protected content")

    assert_no_difference("Post.count") do
      delete post_path(post_record)
    end

    assert_response :see_other
  end

  test "demo account cannot change email" do
    original_email = @demo.email

    patch user_registration_path, params: {
      user: {
        email: "changed@example.invalid",
        current_password: "password123"
      }
    }

    assert_response :see_other
    assert_equal original_email, @demo.reload.email
  end

  test "demo account cannot delete itself" do
    assert_no_difference("User.count") do
      delete user_registration_path
    end

    assert_response :see_other
  end

  test "demo account cannot send friend requests" do
    assert_no_difference("Friendship.count") do
      post friendships_path, params: {
        friend_id: users(:two).id
      }
    end

    assert_response :see_other
  end

  test "demo account can sign out" do
    delete destroy_user_session_path

    assert_response :redirect
  end

  test "regular users can still create posts" do
    sign_out @demo
    sign_in users(:two)

    assert_difference("Post.count", 1) do
      post posts_path, params: {
        post: { content: "Regular user post" }
      }
    end

    assert_response :redirect
  end

  test "demo account cannot access post editing page" do
  post_record = @demo.posts.create!(content: "Protected post")

  get edit_post_path(post_record)

  assert_redirected_to authenticated_root_path
  assert_response :see_other
end

  test "demo account cannot access profile editing page" do
    get edit_profile_path(@demo.profile)

    assert_redirected_to authenticated_root_path
    assert_response :see_other
  end

  test "demo account cannot access registration editing page" do
    get edit_user_registration_path

    assert_redirected_to authenticated_root_path
    assert_response :see_other
  end

  test "demo account cannot access singular profile editing page" do
    get "/profile/edit"

    assert_redirected_to authenticated_root_path
    assert_response :see_other
  end
end
