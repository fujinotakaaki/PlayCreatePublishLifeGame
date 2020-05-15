FactoryBot.define do
  factory :display_format do
    name { Faker::String.random }
    alive { [*?A..?Z].sample }
    dead { [*?a..?z].sample }
    font_color {Faker::Color.hex_color}
    background_color { (%W(#{Faker::Color.hex_color} #114514 #364364) - [font_color]).first }
    line_height_rate { rand(50..100) }
    letter_spacing { rand(-5..15) }
    font_size { rand(5..40) }
    association :user, factory: :user
  end
end
