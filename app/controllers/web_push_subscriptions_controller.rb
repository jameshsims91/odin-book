class WebPushSubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    subscription = current_user.web_push_subscriptions.find_or_initialize_by(
      endpoint: params[:endpoint]
    )

    subscription.update!(
      p256dh_key: params.dig(:keys, :p256dh),
      auth_key: params.dig(:keys, :auth)
    )

    render json: { success: true }, status: :ok
  rescue => e
    Rails.logger.error "WebPush Subscription Failure: #{e.message}"
    render json: { error: "Server Error: #{e.message}" }, status: :internal_server_error
  end
end
