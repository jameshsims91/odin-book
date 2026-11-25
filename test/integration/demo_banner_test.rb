
require "test_helper"

class DemoBannerTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)
  end

  test "demo account sees demo banner" do
    sign_in @demo

    get authenticated_root_path

    assert_response :success
    assert_select "aside.demo-banner", count: 1
    assert_select ".demo-banner-label span",
                  text: "Demo Mode"
  end

  test "regular account does not see demo banner" do
    sign_in @regular

    get authenticated_root_path

    assert_response :success
    assert_select "aside.demo-banner", count: 0
  end

  test "signed out visitor does not see demo banner" do
    get new_user_session_path

    assert_response :success
    assert_select "aside.demo-banner", count: 0
  end

  test "demo banner remains visible on social feed" do
    sign_in @demo

    get posts_path

    assert_response :success
    assert_select "aside.demo-banner", count: 1
  end
end
