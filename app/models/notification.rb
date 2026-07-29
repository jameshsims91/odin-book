class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  default_scope -> { order(created_at: :desc) }

  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end

  after_create :broadcast_browser_push_alerts

  private

  def broadcast_browser_push_alerts
    recipient = self.recipient
    return if recipient.blank?

    alert_title = "OdinBook Update"
    alert_body = case action
    when "liked_post" then "#{actor.name.presence || actor.email} liked your post."
    when "commented_on_post" then "#{actor.name.presence || actor.email} commented on your post."
    when "friend_request" then "#{actor.name.presence || actor.email} sent you a friend request!"
    else "You have received an activity update alert."
    end

    redirect_target_url = "https://herokuapp.com"

    recipient.web_push_subscriptions.find_each do |sub|
      SendWebPushNotificationJob.perform_later(sub.id, alert_title, alert_body, redirect_target_url)
    end
  end
end
