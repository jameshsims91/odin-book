class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = visible_notifications
                       .includes(:actor, :notifiable)
                       .order(created_at: :desc)
    unless current_user.demo_account?
      visible_notifications.unread.each(&:mark_as_read!)
    end
  end

  def clear_all
    visible_notifications.destroy_all
    redirect_to notifications_path, notice: "Notification inbox cleared completely!"
  end
end
