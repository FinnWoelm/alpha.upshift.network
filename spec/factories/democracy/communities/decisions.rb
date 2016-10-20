FactoryGirl.define do
  factory :democracy_community_decision, class: 'Democracy::Community::Decision' do
    association :community, factory: :democracy_community
    association :author, factory: :user
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    ends_at { Faker::Business.credit_card_expiry_date }
  end
end
