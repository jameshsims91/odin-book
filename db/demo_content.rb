demo_seeding_allowed =
  Rails.env.development? ||
  (Rails.env.production? && ENV["SEED_DEMO"] == "true")

abort "Demo seeding is not authorized in this environment." unless demo_seeding_allowed

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
  [ username, User.find_by!(username: username, demo_account: true) ]
end

demo_posts = {
  "odin_demo" => [
    "Welcome to my Odin Book profile! Feel free to explore the social feed, connect with friends, and try out the application.",
    "Learning something new every day is one of the best parts of being a developer."
  ],
  "odin_alex" => [
    "Spent the morning refactoring a Rails application. Small, focused methods make such a difference in readability.",
    "Just finished writing integration tests for a new feature. Nothing beats seeing an entire test suite turn green.",
    "Today's reminder: understanding why your code works is just as important as getting it to work."
  ],
  "odin_maya" => [
    "Working on a new dashboard design today. Accessibility and simplicity are my top priorities.",
    "Good design isn't just about appearance. It's about making technology easier for everyone to use.",
    "Really enjoyed discussing interface design with @odin_olivia. Collaboration always leads to better ideas."
  ],
  "odin_jordan" => [
    "Finally wrapped my head around recursion! Sometimes drawing out the call stack makes everything click.",
    "Practicing Ruby enumerables today. Map, select and reduce are incredibly useful once you understand their differences.",
    "Thanks @odin_demo for connecting! Looking forward to sharing more of my coding journey."
  ],
  "odin_sofia" => [
    "Went on an early morning photography walk. The best moments are often the ones you don't plan.",
    "Experimenting with natural light and composition this weekend. Creativity is a skill worth practicing.",
    "Photography and software development have something in common: both reward patience and attention to detail."
  ],
  "odin_marcus" => [
    "Spent the weekend building a small home lab. There's always something new to learn about Linux.",
    "Exploring cloud hosting options for personal projects. Keeping costs low while maintaining reliability is an interesting challenge.",
    "Anyone working on an exciting side project this week?"
  ],
  "odin_olivia" => [
    "Built a responsive React component today. Mobile-first development makes layout decisions much easier.",
    "Finished improving the keyboard navigation on my latest project. Accessibility should never be an afterthought.",
    "Great conversation with @odin_maya about balancing visual design and usability."
  ]
}

sample_comments = [
  "Thanks for sharing this!",
  "I completely agree. Practice makes a huge difference.",
  "That's a great perspective!",
  "Really enjoyed reading this.",
  "I'm looking forward to seeing your progress.",
  "This is something I've been learning about too.",
  "Great work! Keep it up.",
  "Definitely worth exploring further.",
  "I appreciate the reminder.",
  "Interesting approach. Thanks for the inspiration!"
]

posts = []

ActiveRecord::Base.transaction do
  # Create sample posts.
  demo_posts.each do |username, contents|
    author = users.fetch(username)

    contents.each_with_index do |content, index|
      post = author.posts.find_or_create_by!(content: content) do |record|
        record.created_at = (index + 1).days.ago
      end

      posts << post
    end
  end

  # Add two likes from different demo users to every post.
  posts.each_with_index do |post, index|
    available_users = users.values.reject do |user|
      user.id == post.user_id
    end

    first_user = available_users[index % available_users.length]
    second_user = available_users[(index + 1) % available_users.length]

    [ first_user, second_user ].each do |user|
      Like.find_or_create_by!(
        user: user,
        post: post
      )
    end
  end

  # Add one comment from another demo user to every post.
  posts.each_with_index do |post, index|
    available_users = users.values.reject do |user|
      user.id == post.user_id
    end

    commenter = available_users[(index + 2) % available_users.length]
    content = sample_comments[index % sample_comments.length]

    Comment.find_or_create_by!(
      user: commenter,
      post: post,
      content: content
    )
  end
end

puts "Demo content setup complete!"
puts "Sample posts: #{posts.size}"
puts "Likes on sample posts: #{Like.where(post: posts).count}"
puts "Comments on sample posts: #{Comment.where(post: posts).count}"
