
require "test_helper"

class DemoAccountTest < ActiveSupport::TestCase
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)
  end

  test "demo account cannot change email" do
    assert_not @demo.update(email: "changed@example.invalid")
    assert @demo.errors[:email].any?
  end

  test "demo account cannot change username" do
    assert_not @demo.update(username: "changed_username")
    assert @demo.errors[:username].any?
  end

  test "demo account cannot change password" do
    assert_not @demo.update(
      password: "new-password-12345",
      password_confirmation: "new-password-12345"
    )

    assert @demo.errors[:encrypted_password].any?
  end

  test "demo account cannot remove demo status" do
    assert_not @demo.update(demo_account: false)
    assert @demo.errors[:demo_account].any?
  end

  test "demo account cannot be destroyed" do
    assert_not @demo.destroy
    assert User.exists?(@demo.id)
  end

  test "regular user can change username" do
    user = users(:two)

    assert user.update(username: "updated_username")
  end
end
