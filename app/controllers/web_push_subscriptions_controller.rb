class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    unless current_user
      render json: { error: "Unauthoerized" }, status: :unauthorized
    end
    subscription = current_user.web_push_subscriptions.find_or_initialize_by(
      endpoint: params[:endpoint]
    )
    subscription.update!(
      p256dh: params[:subscription][:keys][:p256dh],
      auth: arams[:subscription][:keys][:auth]
    )
    render json: { status: "subscribed" }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
