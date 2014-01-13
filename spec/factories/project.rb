FactoryGirl.define do
  factory :project do
    title { Faker::Lorem.words(3).join(' ') }
    summary Faker::Lorem.characters(100)
    duration 15
    deadline 5.days.from_now
    goal Faker::Number.number(4)
    published_at 2.hours.from_now
    video_url Faker::Internet.url
    project_state 'draft'
    permalink { title.parameterize }
    deleted_at nil

    association :location

    factory :project_with_pledges do
      ignore do
        pledge_count 5
      end

      after(:create) do |project, evaluator|
        create_list(:pledge, evaluator.pledge_count, project: project)
      end
    end

    factory :project_with_messages do
      ignore do
        message_count 5
      end

      after(:create) do |project, evaluator|
        create_list(:message, evaluator.message_count, project: project)
      end
    end
  end
end