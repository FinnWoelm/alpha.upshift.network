FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.user_name }
    password { Faker::Internet.password(10, 50) }
    name { Faker::Name.name }
    last_seen_at nil
  end
end
