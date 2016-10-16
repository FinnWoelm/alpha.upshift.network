FactoryGirl.define do
  factory :vote do
    association :voter, factory: :user
    association :votable, factory: :democracy_community_decision
    vote { "upvote" }
  end
end
