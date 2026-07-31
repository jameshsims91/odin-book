module PostsHelper
  def render_post_body(content)
    return "" if content.blank?

    escaped_content = h(content)

    # Scans text block for handles like @username and renders custom spans
    parsed_html = escaped_content.gsub(/@(\w+)/) do |match|
      username = $1
      target_user = User.find_by(username: username)

      if target_user
        profile_target = target_user.profile ? profile_path(target_user.profile) : user_path(target_user)
        # CRUCIAL: The class must be inside the link generator options hash
        link_to match, profile_target, class: "user-mention"
      else
        match # Fallback safely if handle does not match an actual database record
      end
    end

    parsed_html.html_safe
  end
end
