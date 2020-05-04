FactoryBot.define do
  factory :display_format do
    name { "sample_display_format" }
    alive { ?■ }
    dead { ?□ }
    font_color { '#000000' }
    background_color { '#123456' }
    line_height_rate { 53 }
    letter_spacing { -3 }
    font_size { 40 }
    association :user, factory: :user
  end
end
