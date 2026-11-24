require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "visitor can access the login page" do
    visit new_user_session_path

    assert_selector "form"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
  end

  test "visitor can access the registration page" do
    visit new_user_registration_path

    assert_selector "form"
    assert_selector "input[type='email']"
    assert_selector "input[type='password']"
  end
end
