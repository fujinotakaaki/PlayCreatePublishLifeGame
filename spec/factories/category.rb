FactoryBot.define do
  factory :category do
    name { Faker::String.random }
    explanation { Faker::String.random.truncate(500) }
  end
end
