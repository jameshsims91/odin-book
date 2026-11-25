
demo_seeding_allowed =
  Rails.env.development? ||
  (Rails.env.production? && ENV["SEED_DEMO"] == "true")

abort "Demo seeding is not authorized in this environment." unless demo_seeding_allowed

puts "Starting OdinBook demo setup."
puts "Environment: #{Rails.env}"
puts

scripts = %w[
  demo_seeds.rb
  demo_content.rb
  demo_images.rb
]

scripts.each do |script|
  abort "Missing seed script: #{script}" unless Rails.root.join("db", script).file?
end

scripts.each do |script|
  puts "========================================"
  puts "Running #{script}"
  puts "========================================"

  load Rails.root.join("db", script)

  puts
end

puts "========================================"
puts "OdinBook demo setup complete!"
puts "========================================"
