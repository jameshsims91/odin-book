module ApplicationHelper
  include Pagy::Frontend

  def user_avatar(user, size: 40)
    avatar_style = "width: #{size}px; height: #{size}px; border-radius: 50%; object-fit: cover; flex-shrink: 0;"

    if user.avatar.attached?
      image_tag user_avatar_path(user),
        class: "user-avatar",
        style: avatar_style,
        alt: user.name.presence || "User Avatar"

    elsif user.avatar_url.present?
      image_tag user.avatar_url,
        class: "user-avatar",
        style: avatar_style,
        alt: user.name.presence || "User Avatar"

    else
      initial = (user.name.presence || user.email).to_s.first.upcase

      content_tag :div, initial,
        class: "user-avatar",
        style: "#{avatar_style} background-color: #dbeafe; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #2563eb; font-size: #{size * 0.4}px; text-transform: uppercase;"
    end
  end

  def render_post_image(post)
    if post.image.attached?
      image_tag post_image_path(post, size: "original"), style: "width: 100%; max-height: 400px; object-fit: cover; border-radius: 8px; margin-top: 12px; border: 1px solid #e5e7eb;", alt: "Post Attachment File"
    end
  end

  def render_post_body(content)
    parts = content.to_s.split(/(@\w+)/)

    safe_join(parts.map do |part|
      if part.match?(/\A@\w+\z/)
        username = part.delete_prefix("@")

        user = User.find_by(
          username: username,
          demo_account: current_user.demo_account?
        )

        if user
          link_to(part, user_profile_path(user), class: "user-mention")
        else
          part
        end
      else
        part
      end
    end)
  end

  def visible_post_comments(post)
    post.comments.where(
      user_id: User.where(
        demo_account: current_user.demo_account?
      ).select(:id)
    )
  end

  def visible_post_likes(post)
    post.likes.where(
      user_id: User.where(
        demo_account: current_user.demo_account?
      ).select(:id)
    )
  end

  def visible_comment_likes(comment)
    comment.comment_likes.where(
      user_id: User.where(
        demo_account: current_user.demo_account?
      ).select(:id)
    )
  end

  def user_profile_path(user)
    return authenticated_root_path if user == current_user

    if user.profile.present?
      profile_path(user.profile)
    else
      user_path(user)
    end
  end

  def demo_mode?
    current_user&.demo_account? || false
  end
end
