class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :user_id, uniqueness: { scope: :friend_id, message: "Request already exists" }
end
