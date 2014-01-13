FactoryGirl.define do
  factory :category do
    name { Faker::Commerce.product_name }

    factory :category_with_projects do
      ignore do
        project_count 5
      end

      after(:create) do |category, evaluator|
        create_list(:project, evaluator.project_count, category: category)
      end
    end
  end
end