FactoryBot.define do
  factory :block, class: Pattern do
    name { 'pattern_block' }
    introduction { 'pattern_block_introduction' }
    is_torus { false }
    margin_top { 1 }
    margin_bottom { 1 }
    margin_left { 1 }
    margin_right { 1 }
    normalized_rows_sequence { '3,3' }
    is_secret { false }
    association :user, factory: :user
    association :category, factory: :category
    association :display_format, factory: :display_format
  end
end
