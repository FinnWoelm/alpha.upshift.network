FactoryGirl.define do
  factory :private_conversation do
    sender { create(:user) }
    recipient { create(:user) }
  end
end
