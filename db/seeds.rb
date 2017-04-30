# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Clear old Paperclip attachments: user images
FileUtils.rm_rf(Dir["#{Rails.root}/uploads/users"])

# Create some users
alice = User.new(
  :name => "Alice",
  :username => "alice",
  :email => "alice@upshift.network",
  :password => "password",
  :confirmed_registration => true,
  :color_scheme => Color.color_options.sample
)

brian = User.new(
  :name => "Brian",
  :username => "brian",
  :email => "brian@upshift.network",
  :password => "password",
  :confirmed_registration => true,
  :color_scheme => Color.color_options.sample
)

carla = User.new(
  :name => "Carla",
  :username => "carla",
  :email => "carla@upshift.network",
  :password => "password",
  :confirmed_registration => true,
  :color_scheme => Color.color_options.sample
)

dennis = User.new(
  :name => "Dennis",
  :username => "dennis",
  :email => "dennis@upshift.network",
  :password => "password",
  :confirmed_registration => true,
  :color_scheme => Color.color_options.sample
)

[alice, brian, carla, dennis].each do |user|
  user.bio = "Hi, my name is #{user.name}! :D"
  user.auto_generate_profile_picture
  user.save
end

# Create Friendships between users
Friendship.create(:initiator => alice, :acceptor => brian)
Friendship.create(:initiator => alice, :acceptor => carla)
Friendship.create(:initiator => alice, :acceptor => dennis)

# Create some private conversations
20.times do |i|
  u = User.new(
    :username => "user#{i}",
    :password => "password",
    :name => "user#{i}",
    :email => "user#{i}@upshift.network",
    :confirmed_registration => true,
    :color_scheme => Color.color_options.sample,
    :visibility => :network,
    :bio => "Hi, my name is user#{i}! :)"
  )
  u.auto_generate_profile_picture
  u.save
  conversation = PrivateConversation.new(:sender => alice, :recipient => u)
  conversation.messages.build(:content => "initial message", :sender => alice)
  conversation.save
end

# Create some private messages
100.times do |i|
  conversation = PrivateConversation.order("RANDOM()").first
  PrivateMessage.create(:sender => alice, :conversation => conversation, :content => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus quis placerat diam. Donec tempor consectetur sem ac accumsan. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Proin aliquam justo vel massa vehicula, id finibus magna auctor. Vivamus luctus tristique quam, in molestie orci convallis sed.")
  if (i+1)%10 == 0
    puts "Generated #{i+1} messages"
  end
end

# Create some posts
100.times do |i|
  author = User.order("RANDOM()").first
  recipient =
    (
      [author] +
      author.friends +
      User.where(:visibility => :public).or(
        User.where(:visibility => :network)
      )
    ).sample
  Post.create(
    :author => author,
    :content => "Post #{i}\nLorem Ipsum Dolorem",
    :recipient => recipient)
end

### Democracy

# Create a Community
# Democracy::Community.create(name: 'Test Community')
