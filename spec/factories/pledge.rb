FactoryGirl.define do
  factory :pledge do
    amount Faker::Number.number(3)

    factory :pledge_with_requested_rewards do
      ignore do
        reward_count 4
      end

      after(:create) do |pledge, evaluator|
        create_list(:requested_reward, evaluator.reward_count, pledge: pledge)
      end
    end
  end
end