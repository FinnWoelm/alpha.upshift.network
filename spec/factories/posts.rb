FactoryGirl.define do
  factory :post do
    association :author, factory: :user
    association :recipient, factory: :user
    content { Faker::Lorem.paragraph }

    factory :post_to_self do
      recipient { author }
    end
  end
end
