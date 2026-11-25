class CommentLike < ApplicationRecord
  include DemoAccountIsolation

  belongs_to :user
  belongs_to :comment

  validates :user_id,
            uniqueness: { scope: :comment_id }

  validate :compatible_accounts

  private

  def compatible_accounts
    validate_account_compatibility(user, comment&.user)
    validate_account_compatibility(user, comment&.post&.user)
  end
end
