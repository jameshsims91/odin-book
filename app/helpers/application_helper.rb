module ApplicationHelper
  def user_avatar(user, size: 40)
    if user.avatar&.attached?
      image_tag user.avatar, style: "width: #{size}px; height: #size}px; border-radius: 50%; object-fit: cover;", alt: user.name || "User Avatar"

    elsif user.avatar_url.present?
      image_tag user.avatar_url, style: "width: #{size}px; height: #{size}px; border-radius: 50%; object-fit: cover;", alt: user.name || "User Avatar"

    else
      initial = (user.name.presence || user.email).to_s.first.upcase
      content_tag :div, initial,
        style: "width: #{size}px; height: #{size}px; background-color: #dbeafe; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #2563eb; font-size: #{size * 0.4}px; text-transform: uppercase;"
    end
  end

  def render_post_image(post)
    if post.image.attached?
      image_tag post.image, style: "width: 100%; max-height: 400px; object-fit: cover; border-radius: 8px; margin-top: 12px; border: 1px solid #e5e7eb;", alt: "Post Attachment File"
    end
  end
end
