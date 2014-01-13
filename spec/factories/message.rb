FactoryGirl.define do
  factory :message do
    subject Faker::Lorem.words(5)
    content Faker::Lorem.paragraph(2)
    association :sender, factory: :user
    association :receiver, factory: :user
    association :project
  end
end