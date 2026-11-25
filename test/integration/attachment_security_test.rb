
require "test_helper"

class AttachmentSecurityTest < ActionDispatch::IntegrationTest
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)

    @demo_post = posts(:one)
    @regular_post = posts(:two)

    attach_test_image(@demo.avatar)
    attach_test_image(@regular.avatar)

    attach_test_image(@demo_post.image)
    attach_test_image(@regular_post.image)
  end

  test "demo user can view demo avatar" do
    sign_in @demo

    get user_avatar_path(@demo)

    assert_response :success
    assert_equal "image/png", response.media_type
  end

  test "demo user cannot view regular user avatar" do
    sign_in @demo

    get user_avatar_path(@regular)

    assert_response :not_found
  end

  test "regular user cannot view demo avatar" do
    sign_in @regular

    get user_avatar_path(@demo)

    assert_response :not_found
  end

  test "regular user can view regular avatar" do
    sign_in @regular

    get user_avatar_path(@regular)

    assert_response :success
    assert_equal "image/png", response.media_type
  end

  test "demo user can view demo post image" do
    sign_in @demo

    get post_image_path(@demo_post, size: "original")

    assert_response :success
    assert_equal "image/png", response.media_type
  end

  test "demo user cannot view regular post image" do
    sign_in @demo

    get post_image_path(@regular_post, size: "original")

    assert_response :not_found
  end

  test "regular user cannot view demo post image" do
    sign_in @regular

    get post_image_path(@demo_post, size: "original")

    assert_response :not_found
  end

  test "regular user can view regular post image" do
    sign_in @regular

    get post_image_path(@regular_post, size: "original")

    assert_response :success
    assert_equal "image/png", response.media_type
  end

  test "regular user can view webp feed image" do
    sign_in @regular

    get post_image_path(@regular_post, size: "feed")

    assert_response :success
    assert_equal "image/webp", response.media_type
  end

  test "regular user can view thumbnail" do
    sign_in @regular

    get post_image_path(@regular_post, size: "thumbnail")

    assert_response :success
    assert_equal "image/webp", response.media_type
  end

  test "invalid image size is rejected" do
    sign_in @regular

    get post_image_path(@regular_post, size: "invalid")

    assert_response :not_found
  end

  test "unauthenticated visitor cannot view avatar" do
    get user_avatar_path(@regular)

    assert_response :not_found
  end

  test "unauthenticated visitor cannot view post image" do
    get post_image_path(@regular_post, size: "original")

    assert_response :not_found
  end

  test "default active storage blob route is disabled" do
    sign_in @regular

    blob = @regular.avatar.blob

    get "/rails/active_storage/blobs/redirect/" \
        "#{blob.signed_id}/#{blob.filename}"

    assert_response :not_found
  end

  test "default direct upload route is disabled" do
    sign_in @regular

    post "/rails/active_storage/direct_uploads"

    assert_response :not_found
  end

  private

  def attach_test_image(attachment)
    File.open(
      Rails.root.join("test/fixtures/files/test_image.png"),
      "rb"
    ) do |file|
      attachment.attach(
        io: file,
        filename: "test_image.png",
        content_type: "image/png"
      )
    end
  end
end
