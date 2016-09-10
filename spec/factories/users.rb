FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    username {
      Faker::Internet.user_name( "#{name}".first(26).strip, %w(_) ) }
    password { Faker::Internet.password(10, 50) }
    last_seen_at nil

    after(:build, :stub) { |user| user.build_profile(attributes_for(:profile)) }

  end
end
