module DemoAccountIsolation
  extend ActiveSupport::Concern

  private

  def validate_account_compatibility(actor, recipient)
    return if actor.nil? || recipient.nil?
    return if actor.demo_account? == recipient.demo_account?

    errors.add(
      :base,
      "Demo and regular accounts cannot interact"
    )
  end
end
