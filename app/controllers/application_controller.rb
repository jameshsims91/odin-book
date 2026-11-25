class ApplicationController < ActionController::Base
  include DemoVisibility
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :protect_demo_account
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

  def protect_demo_account
    return unless current_user&.demo_account?
    return if devise_controller? && controller_name == "sessions"

    read_only_request = request.get? || request.head?
    restricted_page = %w[edit new].include?(action_name)

    return if read_only_request && !restricted_page

    respond_to do |format|
      format.html do
        redirect_to authenticated_root_path,
                    alert: "This action is disabled in demo mode.",
                    status: :see_other
      end

      format.any { head :forbidden }
    end
  end
end
