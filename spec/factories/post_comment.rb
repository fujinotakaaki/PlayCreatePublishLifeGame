FactoryBot.define do
  factory :post_comment do
    body { Faker::String.random.truncate(500) }
    association :user, factory: :user
    association :pattern, factory: :pattern_block # Patternレコード（ブロック）
  end
end
