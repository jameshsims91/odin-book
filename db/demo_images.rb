demo_seeding_allowed =
  Rails.env.development? ||
  (Rails.env.production? && ENV["SEED_DEMO"] == "true")

abort "Demo seeding is not authorized in this environment." unless demo_seeding_allowed

assets_path = Rails.root.join("db", "demo_assets")

usernames = %w[
  odin_demo
  odin_alex
  odin_maya
  odin_jordan
  odin_sofia
  odin_marcus
  odin_olivia
]

users = usernames.to_h do |username|
  [
    username,
    User.find_by!(
      username: username,
      demo_account: true
    )
  ]
end

post_images = [
  {
    username: "odin_alex",
    content: "Spent the morning refactoring a Rails application. Small, focused methods make such a difference in readability.",
    filename: "workspace.webp"
  },
  {
    username: "odin_maya",
    content: "Working on a new dashboard design today. Accessibility and simplicity are my top priorities.",
    filename: "dashboard.webp"
  },
  {
    username: "odin_sofia",
    content: "Went on an early morning photography walk. The best moments are often the ones you don't plan.",
    filename: "photography.webp"
  },
  {
    username: "odin_marcus",
    content: "Spent the weekend building a small home lab. There's always something new to learn about Linux.",
    filename: "homelab.webp"
  },
  {
    username: "odin_olivia",
    content: "Built a responsive React component today. Mobile-first development makes layout decisions much easier.",
    filename: "responsive.webp"
  }
]

attachments = []

# Prepare avatar attachments.
users.each do |username, user|
  attachments << {
    record: user,
    attachment: :avatar,
    path: assets_path.join("avatars", "#{username}.webp"),
    label: "Avatar for #{username}"
  }
end

# Prepare post image attachments.
post_images.each do |attributes|
  user = users.fetch(attributes.fetch(:username))

  post = user.posts.find_by!(
    content: attributes.fetch(:content)
  )

  attachments << {
    record: post,
    attachment: :image,
    path: assets_path.join("posts", attributes.fetch(:filename)),
    label: "Post image for #{user.username}"
  }
end

# Validate every required file before uploading anything.
attachments.each do |attributes|
  path = attributes.fetch(:path)

  abort "Missing image: #{path}" unless File.file?(path)

  if File.size(path) > 5.megabytes
    abort "Image exceeds the 5 MB limit: #{path}"
  end
end

uploaded_count = 0
skipped_count = 0

attachments.each do |attributes|
  record = attributes.fetch(:record)
  attachment = record.public_send(attributes.fetch(:attachment))
  path = attributes.fetch(:path)
  label = attributes.fetch(:label)

  # Preserve existing attachments and prevent duplicate uploads.
  if attachment.attached?
    puts "Skipped existing attachment: #{label}"
    skipped_count += 1
    next
  end

  File.open(path, "rb") do |file|
    attachment.attach(
      io: file,
      filename: path.basename.to_s,
      content_type: "image/webp"
    )

    record.save!
  end

  unless attachment.attached?
    raise "Attachment failed: #{label}"
  end

  uploaded_count += 1
  puts "Attached: #{label}"
end

puts
puts "Demo image setup complete!"
puts "New attachments: #{uploaded_count}"
puts "Existing attachments skipped: #{skipped_count}"
