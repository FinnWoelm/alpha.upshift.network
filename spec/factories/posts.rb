FactoryGirl.define do
  factory :post do
    association :author, factory: :user
    content { Faker::Lorem.paragraph }
  end
end
