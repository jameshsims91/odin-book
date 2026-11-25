demo_seeding_allowed =
  Rails.env.development? ||
  (Rails.env.production? && ENV["SEED_DEMO"] == "true")

abort "Demo seeding is not authorized in this environment." unless demo_seeding_allowed

require "securerandom"

demo_profiles = [
  {
    name: "Demo Explorer",
    username: "odin_demo",
    information: "Exploring Odin Book! This is a fictional portfolio demonstration account."
  },
  {
    name: "Alex Morgan",
    username: "odin_alex",
    information: "Software developer passionate about Ruby, Rails, open-source projects and clean code."
  },
  {
    name: "Maya Chen",
    username: "odin_maya",
    information: "UI/UX designer creating intuitive, accessible and meaningful digital experiences."
  },
  {
    name: "Jordan Ellis",
    username: "odin_jordan",
    information: "Computer science student exploring algorithms, web development and new technologies."
  },
  {
    name: "Sofia Rivera",
    username: "odin_sofia",
    information: "Photographer and creative storyteller. Always looking for a new perspective."
  },
  {
    name: "Marcus Reed",
    username: "odin_marcus",
    information: "Technology enthusiast, gamer and lifelong learner interested in emerging technologies."
  },
  {
    name: "Olivia Brooks",
    username: "odin_olivia",
    information: "Frontend developer passionate about JavaScript, React and responsive web design."
  }
]

users = {}

# Avoid opening welcome emails during local seeding.
original_deliveries = ActionMailer::Base.perform_deliveries
ActionMailer::Base.perform_deliveries = false

begin
  ActiveRecord::Base.transaction do
    demo_profiles.each do |attributes|
      username = attributes.fetch(:username)
      email = "#{username}@example.invalid"

      user = User.find_or_initialize_by(email: email)

      if user.persisted? && (!user.demo_account? || user.username != username)
        raise "Demo account conflict: #{email}"
      end

      if user.new_record?
        password = if username == "odin_demo"
          ENV.fetch("DEMO_PASSWORD")
        else
          SecureRandom.hex(24)
        end

        user.assign_attributes(
          name: attributes.fetch(:name),
          username: username,
          password: password,
          password_confirmation: password,
          demo_account: true
        )

        user.save!
        puts "Created user: #{username}"
      else
        puts "Existing demo user: #{username}"
      end

      profile = user.profile || user.build_profile
      profile.update!(information: attributes.fetch(:information))

      users[username] = user
    end

    explorer = users.fetch("odin_demo")

    %w[odin_alex odin_maya odin_jordan odin_sofia].each do |username|
      Friendship.find_or_create_by!(
        user: explorer,
        friend: users.fetch(username)
      ) do |friendship|
        friendship.status = "accepted"
      end
    end

    %w[odin_marcus odin_olivia].each do |username|
      Friendship.find_or_create_by!(
        user: users.fetch(username),
        friend: explorer
      ) do |friendship|
        friendship.status = "pending"
      end
    end

    puts "Demo friendships created."
  end
ensure
  ActionMailer::Base.perform_deliveries = original_deliveries
end

puts "Demo account setup complete!"
