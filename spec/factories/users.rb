FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    username {
      Faker::Internet.user_name( "#{name}".first(26).strip, %w(_) ) }
    password { Faker::Internet.password(10, 50) }
    color_scheme { Color.color_options.sample }
    last_seen_at nil
    visibility { :network }
    bio { Faker::Lorem.paragraph }

    factory :user_with_picture do
      profile_banner { File.open("#{Rails.root}/spec/support/fixtures/community/user/profile_banner.jpg")}
      after(:build, :stub) do |user|
        user.auto_generate_profile_picture
      end
    end

    factory :public_user do
      visibility { :public }
    end

    factory :network_user do
      visibility { :network }
    end

    factory :private_user do
      visibility { :private }
    end
  end
end
