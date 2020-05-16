FactoryBot.define do
  factory :making_random, class: Making do
    is_torus { [true, false].sample }
    sequence(:normalized_rows_sequence, (3..6).cycle) {|n| Array.new(rand(3..6)){SecureRandom.hex(n)}.join(?,) }
    association :user, factory: :user
    association :display_format, factory: :display_format

    trait :filled_random do
      normalized_rows_sequence { nil }
      sequence(:making_text, (4..10).cycle) {|n| Array.new(rand(2..10), 2**n - 1).map{|i|"%0#{n}b" % (i^rand(2**n))}.join("\n") }
    end

    trait :filled_sample do
      normalized_rows_sequence { nil }
      making_text { "0110\n1011\n1001\n1010" }
    end

    trait :unfilled_sample do
      normalized_rows_sequence { nil }
      making_text { "1\n11\n101\n1001\n10001" }
    end

    trait :unfilled_sample do
      normalized_rows_sequence { nil }
      making_text { "1\n11\n101\n1001\n10001" }
    end
  end

  factory :making_octagon, class: Making do
    margin_top { 2 }
    margin_bottom { 2 }
    margin_left { 2 }
    margin_right { 2 }
    normalized_rows_sequence { '12,2d,12,12,2d,12' }
    association :user, factory: :user
    association :display_format, factory: :display_format
  end

  factory :making_blank, class: Making do
    association :user, factory: :user
    association :display_format, factory: :display_format
  end
end
