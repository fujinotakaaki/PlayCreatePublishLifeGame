FactoryBot.define do
  factory :making_octagon, class: Making do
    margin_top { 2 }
    margin_bottom { 2 }
    margin_left { 2 }
    margin_right { 2 }
    normalized_rows_sequence { '12,2d,12,12,2d,12' }
    association :user, factory: :user
    association :display_format, factory: :display_format
  end
end
