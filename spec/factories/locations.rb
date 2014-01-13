# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name { Faker::Address.city }

    factory :location_with_projects do
      ignore do
        project_count 5
      end

      after(:create) do |location, evaluator|
        create_list(:project, evaluator.project_count, location: location)
      end
    end
  end
end
