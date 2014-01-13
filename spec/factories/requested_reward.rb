FactoryGirl.define do
  factory :requested_reward do
    quantity Faker::Number.digit
    association :reward
  end
end