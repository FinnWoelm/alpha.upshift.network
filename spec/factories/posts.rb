FactoryGirl.define do
  factory :post do
    association :author, factory: :user
    association :recipient, factory: :user
    content { Faker::Lorem.paragraph }
  end

  factory :post_to_self do
    association :author, factory: :user
    recipient { author }
    content { Faker::Lorem.paragraph }
  end
end
