FactoryGirl.define do
  factory :post do
    association :author, factory: :user
    profile { author.profile }
    content { Faker::Lorem.paragraph }
  end
end
