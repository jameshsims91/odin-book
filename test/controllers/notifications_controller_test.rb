require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get notifications" do
    get notifications_path

    assert_response :success
  end

  test "should mark notifications as read" do
    notification = notifications(:one)

    assert_nil notification.read_at

    get notifications_path

    assert_response :success
    assert_not_nil notification.reload.read_at
  end
end
