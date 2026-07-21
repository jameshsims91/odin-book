class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :user_id, uniqueness: { scope: :post_id }

  after_create :create_notification

  private

  def create_notification
    return if post.user == user

    Notification.create!(
      recipient: post.user,
      actor: user,
      action: "liked_post",
      notifiable: post
    )
  end
end
