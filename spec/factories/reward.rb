FactoryGirl.define do
  factory :reward do
    minimum_amount Faker::Number.number(2)
    description Faker::Lorem.characters(100)
    estimated_delivery_on 2.months.from_now
    quantity Faker::Number.number(3)
    remaining_quantity Faker::Number.number(2)
  end
end