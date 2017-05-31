FactoryGirl.define do
  factory :account do
    email { Faker::Internet.email }
    password { Faker::Internet.password(10, 50) }
  end
end
