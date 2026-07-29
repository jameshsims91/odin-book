class WebPushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  class WebPushSubscriptionsController e
      render json: { error: "Server Error: #{e.message}" }, internal_server_error
    end
end
