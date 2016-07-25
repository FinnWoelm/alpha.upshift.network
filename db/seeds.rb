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
  :email => "alice",
  :password => "alice"
)

bob = User.create(
  :name => "Bob",
  :username => "bob",
  :email => "bob",
  :password => "bob"
)

carla = User.create(
  :name => "Carla",
  :username => "carla",
  :email => "carla",
  :password => "carla"
)

dennis = User.create(
:name => "Dennis",
:username => "dennis",
:email => "dennis",
:password => "dennis"
)


# Create some private conversations
conversations = []
20.times do |i|
 u = User.create(:username => "user#{i}", :password => "user#{i}", :name => "user#{i}", :email => "user#{i}")
  conversations << PrivateConversation.create(:sender => alice, :recipient => u)
end

# Create some private messages
100.times do |i|
  conversation = conversations[rand(0..conversations.size-1)]
  PrivateMessage.create(:sender => alice, :conversation => conversation, :content => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus quis placerat diam. Donec tempor consectetur sem ac accumsan. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Proin aliquam justo vel massa vehicula, id finibus magna auctor. Vivamus luctus tristique quam, in molestie orci convallis sed.")
  if (i+1)%10 == 0
    puts "Generated #{i+1} messages"
  end
end
