
require "test_helper"

class DemoPasswordSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)
  end

  test "demo account cannot generate password reset token" do
    assert_no_changes -> { @demo.reload.reset_password_token } do
      post user_password_path, params: {
        user: { email: @demo.email }
      }
    end

    assert_response :redirect
    assert_nil @demo.reload.reset_password_sent_at
  end

  test "regular account can generate password reset token" do
    assert_changes -> { @regular.reload.reset_password_token } do
      post user_password_path, params: {
        user: { email: @regular.email }
      }
    end

    assert_response :redirect
    assert_not_nil @regular.reload.reset_password_sent_at
  end
end
