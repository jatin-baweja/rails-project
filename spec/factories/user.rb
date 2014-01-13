FactoryGirl.define do
  factory :user do
    name "Sample Name"
    email { Faker::Internet.email }
    email_confirmation { email }
    password { Faker::Lorem.characters(12) }
    password_confirmation { password }

    factory :admin do
      admin true
    end
  end
end