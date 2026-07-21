class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :pending_follow_requests_count, :unread_notifications_count

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def index
  end

  def pending_follow_requests_count
    return 0 unless user_signed_in?
    @pending_follow_requests_count ||= current_user.inverse_friendships.where(status: "pending").count
  end

  def unread_notifications_count
    return 0 unless user_signed_in?
    @unread_notifications_count ||= current_user.notifications.unread.count
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :name, :avatar ])
  end
end
