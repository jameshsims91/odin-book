class WebPushSubscriptionsController  e
    render json: { error: e.message }, status: :unprocessable_entity
end
