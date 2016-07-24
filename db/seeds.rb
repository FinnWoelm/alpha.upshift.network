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
PrivateConversation.create([
  {:sender => alice, :recipient => bob},
  {:sender => carla, :recipient => alice},
  {:sender => dennis, :recipient => alice},
])
