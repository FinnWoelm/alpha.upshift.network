FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    username {
      Faker::Internet.user_name( "#{name}".first(26).strip, %w(_) ) }
    password { Faker::Internet.password(10, 50) }
    color_scheme { Color.color_options.sample }
    last_seen_at nil
    confirmed_registration true
    visibility { :network }

    after(:build, :stub) do |user|
      user.auto_generate_profile_picture
      user.build_profile(attributes_for(:profile))
    end

  end
end
