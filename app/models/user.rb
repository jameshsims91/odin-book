class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :wordpress, :github ]

  has_one :profile, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy

  after_create :create_default_profile

  USERNAME_REGEX = /\A[a-zA-Z0-9_]{3,23}\z/

  validates :name, presence: true
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: USERNAME_REGEX, message: "only allows letters, numbers, and underscores" }

  def self.from_omniauth(auth, current_user = nil)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)
    return identity.user if identity

    if current_user
      current_user.identities.create!(provider: auth.provider, uid: auth.uid)
      return current_user
    end

    email = auth.info.email
    user = User.find_by(email: email) if email.present?

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

  private

  def create_default_profile
    create_profile(information: "Welcome to my profile!", picture_url: avatar_url)
  end
end
