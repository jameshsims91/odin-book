class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :user_id, uniqueness: { scope: :friend_id, message: "Request already exists" }

  after_create :create_notification

  private

  def create_notification
    Notification.create!(
      recipient: friend,
      actor: user,
      action: "follow_request",
      notifiable: self
    )
  end
end
