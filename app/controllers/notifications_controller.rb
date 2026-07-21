class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.includes(:actor, :notifiable).order(created_at: :desc)
    current_user.notifications.unread.each(&:mark_as_read!)
  end

  def clear_all
    current_user.notifications.destroy_all
    redirect_to notifications_path, notice: "Notification inbox cleared completely!"
  end
end
