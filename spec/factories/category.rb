FactoryBot.define do
  factory :category do
    name { Faker::Game.genre }
    explanation { Faker::Lorem.sentence.truncate(500) }
  end
end
