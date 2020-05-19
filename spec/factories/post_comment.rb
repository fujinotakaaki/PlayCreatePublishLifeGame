FactoryBot.define do
  factory :comment, class: PostComment do
    body { Faker::Lorem.sentence.truncate(500) }
    association :user, factory: :user
    association :pattern, factory: :pattern
  end
end
