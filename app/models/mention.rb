class Mention < ApplicationRecord
  include DemoAccountIsolation

  belongs_to :post
  belongs_to :user

  validate :compatible_accounts

  private

  def compatible_accounts
    validate_account_compatibility(post&.user, user)
  end
end
