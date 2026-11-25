
require "test_helper"

class DemoAccountIsolationTest < ActiveSupport::TestCase
  setup do
    @demo = users(:one)
    @demo.update!(demo_account: true)

    @regular = users(:two)
    @demo_post = posts(:one)
    @regular_post = posts(:two)
  end

  test "regular user cannot send demo user a friend request" do
    friendship = Friendship.new(
      user: @regular,
      friend: @demo,
      status: "pending"
    )

    assert_not friendship.valid?
    assert_includes friendship.errors[:base],
                    "Demo and regular accounts cannot interact"
  end

  test "demo user cannot send regular user a friend request" do
    friendship = Friendship.new(
      user: @demo,
      friend: @regular,
      status: "pending"
    )

    assert_not friendship.valid?
    assert friendship.errors[:base].any?
  end

  test "regular user cannot like demo post" do
    like = Like.new(
      user: @regular,
      post: @demo_post
    )

    assert_not like.valid?
    assert like.errors[:base].any?
  end

  test "demo user cannot like regular post" do
    like = Like.new(
      user: @demo,
      post: @regular_post
    )

    assert_not like.valid?
    assert like.errors[:base].any?
  end

  test "regular user cannot comment on demo post" do
    comment = Comment.new(
      user: @regular,
      post: @demo_post,
      content: "Cross-account comment"
    )

    assert_not comment.valid?
    assert comment.errors[:base].any?
  end

  test "demo user cannot comment on regular post" do
    comment = Comment.new(
      user: @demo,
      post: @regular_post,
      content: "Cross-account comment"
    )

    assert_not comment.valid?
    assert comment.errors[:base].any?
  end

  test "regular user cannot like demo comment" do
    comment = Comment.create!(
      user: @demo,
      post: @demo_post,
      content: "Demo comment"
    )

    like = CommentLike.new(
      user: @regular,
      comment: comment
    )

    assert_not like.valid?
    assert like.errors[:base].any?
  end

  test "regular post cannot mention demo user" do
    post_record = @regular.posts.create!(
      content: "Hello @#{@demo.username}"
    )

    assert_empty post_record.mentioned_users
  end

  test "demo post cannot mention regular user" do
    post_record = @demo.posts.create!(
      content: "Hello @#{@regular.username}"
    )

    assert_empty post_record.mentioned_users
  end

  test "regular user can comment on regular post" do
    comment = Comment.new(
      user: @regular,
      post: @regular_post,
      content: "Allowed comment"
    )

    assert comment.valid?
  end

  test "demo user can have seeded demo comments" do
    comment = Comment.new(
      user: @demo,
      post: @demo_post,
      content: "Allowed demo comment"
    )

    assert comment.valid?
  end
end
