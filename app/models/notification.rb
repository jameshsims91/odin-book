class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  default_scope -> { order(created_at: :desc) }

  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end
end
