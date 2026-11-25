
require "test_helper"

class RedirectLoggingTest < ActionDispatch::IntegrationTest
  test "signed storage URLs are filtered" do
    url = "https://storage.example.com/image.webp?" \
          "X-Amz-Signature=test-signature"

    assert_equal "[FILTERED]", build_response(url).filtered_location
  end

  test "signed storage credential identifiers are filtered" do
    url = "https://storage.example.com/image.webp?" \
          "X-Amz-Credential=test-credential"

    assert_equal "[FILTERED]", build_response(url).filtered_location
  end

  test "supabase storage redirect URLs are filtered" do
    url = "https://example.storage.supabase.co/storage/v1/s3/image.webp"

    assert_equal "[FILTERED]", build_response(url).filtered_location
  end

  test "filtering does not modify the actual redirect location" do
    url = "https://storage.example.com/image.webp?" \
          "X-Amz-Signature=test-signature"

    redirect_response = build_response(url)

    assert_equal "[FILTERED]", redirect_response.filtered_location
    assert_equal url, redirect_response.location
  end

  test "ordinary redirect URLs remain visible" do
    url = "https://odinbook.example.com/dashboard"

    assert_equal url, build_response(url).filtered_location
  end

  test "ordinary redirect query parameters remain visible" do
    url = "https://odinbook.example.com/users?page=2"

    assert_equal url, build_response(url).filtered_location
  end

  test "sensitive redirect query parameters remain filtered" do
    url = "https://odinbook.example.com/account?token=test-token"

    filtered = build_response(url).filtered_location

    assert_includes filtered, "[FILTERED]"
    refute_includes filtered, "test-token"
  end

  private

  def build_response(location)
    request = ActionDispatch::Request.new(
      Rails.application.env_config.dup
    )

    response = ActionDispatch::Response.new(302)
    response.request = request
    response.location = location
    response
  end
end
