class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  before_validation :set_default_status, on: :create

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :user_id, uniqueness: { scope: :friend_id, message: "Request already exists" }

  scope :accepted, -> { where(status: "accepted") }
  scope :pending, -> { where(status: "pending") }

  after_create :create_notification

  private

  def set_default_status
    self.status ||= "pending"
  end

  def create_notification
    Notification.create!(
      recipient: friend,
      actor: user,
      action: "friend_request",
      notifiable: self
    )
  end
end
