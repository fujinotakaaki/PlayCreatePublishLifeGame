FactoryBot.define do
  factory :pattern_random, class: Pattern do
    name { Faker::String.random }
    introduction { Faker::String.random.truncate(500) }
    margin_top { rand(5) }
    margin_bottom { rand(5) }
    margin_left { rand(5) }
    margin_right { rand(5) }
    sequence(:normalized_rows_sequence, (3..6).cycle) {|n| Array.new(rand(3..6)){SecureRandom.hex(n)}.join(?,) }
    association :user, factory: :user
    association :category, factory: :category
    association :display_format, factory: :display_format
  end

  factory :pattern_block, class: Pattern do
    name { 'ブロック' }
    introduction { 'セルが４個の固定物体です。' }
    margin_top { 1 }
    margin_bottom { 1 }
    margin_left { 1 }
    margin_right { 1 }
    normalized_rows_sequence { '3,3' }
    association :user, factory: :user
    association :category, factory: :category
    association :display_format, factory: :display_format
  end
end
