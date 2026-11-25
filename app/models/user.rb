class User < ApplicationRecord
  include ImageValidatable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_one :profile, dependent: :destroy
  has_one_attached :avatar
  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy

  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_many :comment_likes, dependent: :destroy
  has_many :liked_comments, through: :comment_likes, source: :comment

  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :triggered_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy
  has_many :mentions
  has_many :mentioned_in_posts, through: :mentions, source: :post
  has_many :web_push_subscriptions, dependent: :destroy

  after_create :create_default_profile
  after_create :send_welcome_email

  USERNAME_REGEX = /\A[a-zA-Z0-9_]{3,23}\z/
  validates :name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { with: USERNAME_REGEX, message: "only allows letters, numbers, and underscores" }
  validate :acceptable_avatar
  validate :protect_demo_credentials, on: :update
  before_destroy :prevent_demo_account_deletion

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
    compatible_users = User.where(demo_account: demo_account?)

    compatible_users.where(
      id: friendships.accepted.select(:friend_id)
    ) +
      compatible_users.where(
        id: inverse_friendships.accepted.select(:user_id)
      )
  end

  def all_friends
    friends.uniq
  end

  def friends_count
    all_friends.count
  end

  def pending_incoming_requests
    inverse_friendships.pending.where(
      user_id: User.where(
        demo_account: demo_account?
      ).select(:id)
    )
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
    posts.joins(:likes).where(
      likes: {
        user_id: User.where(
          demo_account: demo_account?
        ).select(:id)
      }
    ).count
  end

  def send_reset_password_instructions
    return if demo_account?

    super
  end

  private

  def create_default_profile
    create_profile(information: "Welcome to my profile!", picture_url: avatar_url)
  end

  def send_welcome_email
    if Rails.env.development?
      UserMailer.welcome_email(self).deliver_now
    end
  end

  def acceptable_avatar
    validate_image_attachment(avatar, :avatar)
  end

  def protect_demo_credentials
    return unless demo_account_in_database

    protected_attributes = %w[
      email
      encrypted_password
      username
      demo_account
    ]

    protected_attributes.each do |attribute|
      if will_save_change_to_attribute?(attribute)
        errors.add(attribute, "cannot be changed for a demo account")
      end
    end
  end

  def prevent_demo_account_deletion
    return unless demo_account_in_database

    errors.add(:base, "Demo accounts cannot be deleted")
    throw :abort
  end
end
