module ImageValidatable
  extend ActiveSupport::Concern

  ALLOWED_IMAGE_TYPES = %w[
    image/jpeg
    image/png
    image/webp
    image/gif
  ].freeze

  MAX_IMAGE_SIZE = 5.megabytes

  private

  def validate_image_attachment(attachment, attribute)
    return unless attachment.attached?

    unless ALLOWED_IMAGE_TYPES.include?(attachment.blob.content_type)
      errors.add(attribute, "must be a JPEG, PNG, WebP, or GIF")
    end

    if attachment.blob.byte_size > MAX_IMAGE_SIZE
      errors.add(attribute, "must be smaller than or equal to 5 MB")
    end
  end
end
