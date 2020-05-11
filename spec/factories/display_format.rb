FactoryBot.define do
  factory :display_format do
    name { Faker::String.random }
    sequence(:alive, ?漢){|str|str.chr}
    sequence(:dead, ?　){|str|str.chr}
    font_color {Faker::Color.hex_color}
    background_color { (%W(#{Faker::Color.hex_color} #114514 #364364) - [font_color]).first }
    line_height_rate { rand(100) }
    letter_spacing { rand(-5..15) }
    font_size { rand(100) }
    association :user, factory: :user
  end
end
