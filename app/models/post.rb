class Post < ApplicationRecord
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user
  has_many :comments, dependent: :destroy

  validates :content, presence: true, length: { maximum: 560 }
  default_scope -> { order(created_at: :desc) }
end
