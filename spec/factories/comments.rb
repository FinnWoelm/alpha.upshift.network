FactoryGirl.define do
  factory :comment do
    association :author, factory: :user
    association :commentable, factory: :post
    content { Faker::Lorem.paragraph }
  end
end
