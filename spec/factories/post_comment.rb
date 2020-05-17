FactoryBot.define do
  factory :comment, class: PostComment do
    body { Faker::String.random.truncate(500) }
    association :user, factory: :user
    association :pattern, factory: :pattern
  end
end
