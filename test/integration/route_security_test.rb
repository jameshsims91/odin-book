require "test_helper"

class RouteSecurityTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
  end

  test "cannot create likes through GET requests" do
    assert_no_difference("Like.count") do
      get "/likes/create",
          params: { post_id: posts(:two).id }
    end

    assert_response :not_found
  end

  test "cannot destroy likes through GET requests" do
    assert_no_difference("Like.count") do
      get "/likes/destroy",
          params: { post_id: posts(:one).id }
    end

    assert_response :not_found
  end
end
