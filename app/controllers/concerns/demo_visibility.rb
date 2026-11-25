module DemoVisibility
  extend ActiveSupport::Concern

  private

  def visible_users
    User.where(demo_account: current_user.demo_account?)
  end

  def visible_posts
    Post.where(user_id: visible_users.select(:id))
  end

  def visible_profiles
    Profile.where(user_id: visible_users.select(:id))
  end

  def visible_friends(user = current_user)
    user.friends.select do |friend|
      friend.demo_account? == current_user.demo_account?
    end
  end

  def visible_comments
    Comment.where(
      post_id: visible_posts.select(:id),
      user_id: visible_users.select(:id)
    )
  end

  def visible_friendships
    Friendship.where(
      user_id: visible_users.select(:id),
      friend_id: visible_users.select(:id)
    )
  end

  def visible_notifications
    current_user.notifications.where(
      actor_id: visible_users.select(:id)
    )
  end
end
