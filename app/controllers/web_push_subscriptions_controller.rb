class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    head :service_unavailable
  end
end
