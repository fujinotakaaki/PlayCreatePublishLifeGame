FactoryBot.define do
  factory :making do
    association :user, factory: :user
    # association :display_format, factory: :display_format

    factory :making_random do
      is_torus { [true, false].sample }
      margin_top { rand(5) }
      margin_bottom { rand(5) }
      margin_left { rand(5) }
      margin_right { rand(5) }
      sequence( :normalized_rows_sequence, (3..6).cycle) {|n| Array.new(rand(3..6)){SecureRandom.hex(n)}.join(?,) }
      association :display_format, factory: :display_format
    end

    trait :filled_random do
      is_torus { [true, false].sample }
      # normalized_rows_sequence { nil }
      sequence(:making_text, (4..10).cycle) {|n| Array.new(rand(2..10), 2**n - 1).map{|i|"%0#{n}b" % (i^rand(2**n))}.join("\n") }
    end

    trait :filled_sample do
      # normalized_rows_sequence { nil }
      making_text { "0110\n1011\n1001\n1010" }
    end

    trait :unfilled_sample do
      # normalized_rows_sequence { nil }
      making_text { "1\n11\n101\n1001\n10001" }
    end
  end
end
