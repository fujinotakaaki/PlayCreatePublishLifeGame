FactoryBot.define do
  factory :post_comment do
    sequence(:body) { |n| "post_comment_#{n}" }
    association :user, factory: :user
    association :pattern, factory: :pattern_block # Patternレコード（ブロック）
  end
end
