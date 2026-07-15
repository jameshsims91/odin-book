module ApplicationHelper
  def user_avatar(user, size: 40)
    if user.avatar_url.present?
      image_tag user.avatar_url, size: "#{size}x#{size}", class: "rounded-full object-cover", alt: user.name || "User Avatar"
    else
      initial = (user.name.presence || user.email).to_s.first.upcase
      content_tag :div, initial,
        class: "flex items-center justify-center bg-gray-300 text-gray-700 font-bold rounded-full",
        style: "width: #{size}px; height: #{size}px;"
    end
  end
end
