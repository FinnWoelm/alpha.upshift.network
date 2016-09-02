FactoryGirl.define do
  factory :profile do
    user
    visibility { "is_network_only" }
  end
end
