# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create some users
alice = User.create(
  :name => "Alice",
  :username => "alice",
  :email => "alice@upshift.network",
  :password => "password",
  :confirmed_registration => true
)

bob = User.create(
  :name => "Bob",
  :username => "bob",
  :email => "bob@upshift.network",
  :password => "password",
  :confirmed_registration => true
)

carla = User.create(
  :name => "Carla",
  :username => "carla",
  :email => "carla@upshift.network",
  :password => "password",
  :confirmed_registration => true
)

dennis = User.create(
:name => "Dennis",
:username => "dennis",
:email => "dennis@upshift.network",
:password => "password",
:confirmed_registration => true
)

[alice, bob, carla, dennis].each do |user|
  Profile.create(:user => user)
end

# Create Friendships between users
Friendship.create(:initiator => alice, :acceptor => bob)
Friendship.create(:initiator => alice, :acceptor => carla)
Friendship.create(:initiator => alice, :acceptor => dennis)

# Create some private conversations
conversations = []
20.times do |i|
 u = User.create(:username => "user#{i}", :password => "password", :name => "user#{i}", :email => "user#{i}@upshift.network", :confirmed_registration => true)
 Profile.create(:user => u)
 PrivateConversation.new(:sender => alice, :recipient => u)
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
  Post.create(:author => User.order("RANDOM()").first, :content => "Post #{i}\nLorem Ipsum Dolorem")
end
