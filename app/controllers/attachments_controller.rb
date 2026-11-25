
class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  def avatar
    user = visible_users.find(params[:id])

    return head :not_found unless user.avatar.attached?

    serve_image(user.avatar.blob)
  end

  def post_image
    post_record = visible_posts.find(params[:id])

    return head :not_found unless post_record.image.attached?

    image = post_record.image

    case params[:size]
    when "thumbnail"
      image = image.variant(
        resize_to_limit: [ 100, 100 ],
        format: :webp
      ).processed
    when "feed"
      image = image.variant(
        resize_to_limit: [ 800, 800 ],
        format: :webp
      ).processed
    when "original"
      image = image.blob
    else
      return head :not_found
    end

    serve_image(image)
  end

  private

  def serve_image(image)
    response.headers["Cache-Control"] = "private, no-store"

    if Rails.env.production?
      redirect_to image.url(
        expires_in: 1.minute,
        disposition: :inline
      ), allow_other_host: true
    else
      send_data image.download,
                type: image.content_type,
                disposition: :inline
    end
  end
end
