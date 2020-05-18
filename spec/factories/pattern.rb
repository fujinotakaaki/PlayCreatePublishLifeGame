FactoryBot.define do
  factory :pattern do
    name { Faker::String.random }
    introduction { Faker::String.random.truncate(500) }
    margin_top { rand(5) }
    margin_bottom { rand(5) }
    margin_left { rand(5) }
    margin_right { rand(5) }
    image {Faker::Avatar.image}
    is_torus{[true, false].sample}
    sequence(:normalized_rows_sequence, (3..6).cycle) {|n| Array.new(rand(3..6)){SecureRandom.hex(n)}.join(?,) }
    association :user, factory: :user
    association :category, factory: :category
    association :display_format, factory: :display_format

    factory :block do
      name { 'ブロック' }
      introduction { 'セルが４個の固定物体です。' }
      margin_top { 1 }
      margin_bottom { 1 }
      margin_left { 1 }
      margin_right { 1 }
      normalized_rows_sequence { '3,3' }
    end

    factory :glider do
      name { 'グライダー' }
      introduction { '最小の移動物体。ループします。' }
      margin_top { 1 }
      margin_bottom { 1 }
      margin_left { 1 }
      margin_right { 1 }
      normalized_rows_sequence { '2,1,7' }
      is_torus { true }
    end

    factory :octagon do
      name { '八角形' }
      introduction { '周期5のパターンです。' }
      margin_top { 2 }
      margin_bottom { 2 }
      margin_left { 2 }
      margin_right { 2 }
      normalized_rows_sequence { '12,2d,12,12,2d,12' }
    end

    factory :step4 do
      name { '階段（４段）' }
      introduction { '右肩下がりの４段の階段' }
      margin_top { 1 }
      margin_bottom { 1 }
      margin_left { 1 }
      margin_right { 1 }
      normalized_rows_sequence { '8,c,e,f' }
    end
  end
end
