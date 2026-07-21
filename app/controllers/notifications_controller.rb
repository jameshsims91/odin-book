class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.includes(:actor, :notifiable)
    current_user.notifications.unread.each(&:mark_as_read!)
  end
end
