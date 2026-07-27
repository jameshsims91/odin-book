class Post < ApplicationRecord
  belongs_to :user

  has_one_attached :image
  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user
  has_many :comments, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :mentioned_users, through: :mentions, source: :user
  validates :content, presence: true, length: { maximum: 560 }, unless: -> { image.attached? }
  default_scope -> { order(created_at: :desc) }

  after_save :create_mentions

  private

  def create_mentions
    extracted_username = content.scan(/@(\w+)/).flatten.uniq
    matching_users = User.where(username: extracted_usernames)
    self.mentioned_users = matching_users
    matching_users.each do |tagged_user|
      next if tagged_user == self.user
      Notification.find_or_create_by!(
        recipient: tagged_ser,
        actor: self.user,
        notifiable: self,
        action: "tagged"
      )
    end
  end
end
