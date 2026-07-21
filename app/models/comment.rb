class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :comment_likes, dependent: :destroy
  has_many :liking_users, through: :comment_likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }
  default_scope -> { order(created_at: :asc) }

  after_create :create_notification

  private

  def create_notification
    return if post.user == user

    Notification.create!(
      recipient: post.user,
      actor: user,
      action: "commented_on_post",
      notifiable: post
    )
  end
end
