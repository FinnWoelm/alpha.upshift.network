FactoryGirl.define do
  factory :democracy_community, :class => Democracy::Community do
    name { Faker::Name.name }
  end
end
