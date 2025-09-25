require 'json'

BASE_URL = 'http://localhost:3000'
TOTAL_POSTS = 200_000
TOTAL_USERS = 100
TOTAL_IPS = 50
RATING_PERCENTAGE = 0.75

def check_server
  system("curl -s #{BASE_URL}/up > /dev/null")
  unless $?.success?
    puts "Rails server not running on #{BASE_URL}"
    puts "Start server with: rails server"
    exit(1)
  end
end

def generate_users
  (1..TOTAL_USERS).map { |i| "user#{i.to_s.rjust(3, '0')}" }
end

def generate_ips
  (1..TOTAL_IPS).map { |i| "192.168.#{(i / 256) + 1}.#{i % 256}" }
end

def create_posts
  puts "Creating #{TOTAL_POSTS} posts..."
  users = generate_users
  ips = generate_ips
  post_ids = []

  (1..TOTAL_POSTS).each do |i|
    post_data = {
      title: "Post #{i}",
      body: "Content for post number #{i}",
      user_login: users.sample,
      user_ip: ips.sample
    }.to_json

    result = `curl -s -X POST #{BASE_URL}/api/1/posts \
      -H "Content-Type: application/json" \
      -d '#{post_data}'`

    if $?.success?
      response = JSON.parse(result)
      post_ids << response['post']['id']
    end

    puts "Created #{i} posts" if i % 10_000 == 0
  end

  post_ids
end

def create_ratings(post_ids)
  posts_to_rate = post_ids.sample((post_ids.length * RATING_PERCENTAGE).to_i)
  puts "Creating ratings for #{posts_to_rate.length} posts..."

  posts_to_rate.each_with_index do |post_id, index|
    num_ratings = rand(1..3)

    num_ratings.times do
      rating_data = {
        post_id:,
        user_id: rand(1..TOTAL_USERS),
        value: rand(1..5)
      }.to_json

      system("curl -s -X POST #{BASE_URL}/api/1/ratings \
        -H 'Content-Type: application/json' \
        -d '#{rating_data}' > /dev/null")
    end

    puts "Rated #{index + 1} posts" if (index + 1) % 10_000 == 0
  end
end

puts "Starting seeding process..."
puts "Target: #{TOTAL_POSTS} posts, #{TOTAL_USERS} users, #{TOTAL_IPS} IPs"

check_server

start_time = Time.now
post_ids = create_posts
create_ratings(post_ids)
duration = (Time.now - start_time).round(2)

puts "Completed in #{duration} seconds"
puts "Created #{post_ids.length} posts with ratings"
