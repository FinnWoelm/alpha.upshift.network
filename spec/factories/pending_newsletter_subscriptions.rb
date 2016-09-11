FactoryGirl.define do
  factory :pending_newsletter_subscription do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    signup_url { Faker::Internet.url }
    ip_address { Faker::Internet.ip_v4_address }

    after(:build, :stub) { |pns| pns.regenerate_confirmation_token }
  end
end
