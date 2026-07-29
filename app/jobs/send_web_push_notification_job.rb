class SendWebPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(subscription_id, title_text, body_text, target_url)
    subscription = WebPushSubscription.find_by(id: subscription_id)
    return if subscription.blank?

    message_payload = {
      title: title_text,
      body: body_text,
      url: target_url
    }.to_json

    begin
      WebPush.payload_send(
        message: message_payload,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh_key,
        auth: subscription.auth_key,
        vapid: {
          subject: ENV["VAPID_SUBJECT"],
          public_key: ENV["VAPID_PUBLIC_KEY"],
          private_key: ENV["VAPID_PRIVATE_KEY"]
        }
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      # Automatically prune obsolete browser data keys if users revoke permission
      subscription.destroy
    rescue => e
      Rails.logger.error "WebPush server delivery exception handled: #{e.message}"
    end
  end
end
