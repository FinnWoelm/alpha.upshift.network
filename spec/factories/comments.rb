FactoryGirl.define do
  factory :comment do
    association :author, factory: :user
    post
    content { Faker::Lorem.paragraph }
  end
end
