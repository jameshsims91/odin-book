class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :wordpress, :github ]

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [ :wordpress, :github ]

  has_one :profile, dependent: :destroy
  has_one_attached :avatar
  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_many :comment_likes, dependent: :destroy
  has_many :liked_comments, through: :comment_likes, source: :comment

  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy

  after_create :create_default_profile
  after_create :send_welcome_email

  USERNAME_REGEX = /\A[a-zA-Z0-9_]{3,23}\z/
  validates :name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { with: USERNAME_REGEX, message: "only allows letters, numbers, and underscores" }

  def self.from_omniauth(auth, current_user = nil)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity
    if current_user
      current_user.identities.create!(provider: auth.provider, uid: auth.uid)
      return current_user
    end
    email = auth.info.email
    user = User.find_by(email: email)
    if email.present?
      if user.nil?
        name_fallback = auth.info.name.presence || auth.info.nickname.presence || email.split("@").first
        raw_username = auth.info.nickname.presence || email.split("@").first
        clean_username = raw_username.downcase.gsub(/[^a-z0-9_]/, "_")
        clean_username = "user_#{SecureRandom.hex(4)}" if clean_username.blank?
        user = User.new(
          email: email,
          password: Devise.friendly_token[0, 20],
          name: name_fallback,
          username: clean_username,
          avatar_url: auth.info.image
        )
        user.save!
      end
      user.identities.create!(provider: auth.provider, uid: auth.uid)
      user
    end
  end

  def friends
    User.where(id: friendships.accepted.select(:friend_id)) +
    User.where(id: inverse_friendships.accepted.select(:user_id))
  end

  def all_friends
    friends.uniq
  end

  def friends_count
    all_friends.count
  end

  def pending_incoming_requests
    inverse_friendships.pending
  end

  def friendship_status_with(other_user)
    return :self if self == other_user
    outbound = friendships.find_by(friend_id: other_user.id)
    return outbound.status.to_sym if outbound
    inbound = inverse_friendships.find_by(user_id: other_user.id)
    return :incoming_pending if inbound && inbound.status == "pending"
    return :accepted if inbound && inbound.status == "accepted"
    :none
  end

  def mutual_friends_with(other_user)
    return [] if self == other_user
    self.all_friends & other_user.all_friends
  end

  def liked?(post)
    liked_posts.include?(post)
  end

  def liked_comment?(comment)
    liked_comments.include?(comment)
  end

  def total_posts_count
    posts.count
  end

  def total_likes_received_count
    posts.joins(:likes).count
  end

  private

  def create_default_profile
    create_profile(information: "Welcome to my profile!", picture_url: avatar_url)
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
end
