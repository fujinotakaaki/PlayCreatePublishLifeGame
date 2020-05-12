FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "example#{n}@user.com" }
    password { SecureRandom.alphanumeric }
    password_confirmation { password }
    confirmed_at { Time.zone.now }
    name {Faker::Name.name}
    trait :for_attributes do
      email { nil }
      password { nil }
      password_confirmation { nil }
      confirmed_at { nil }
      name {Faker::Name.name}
      introduction {Faker::String.random.truncate(500)}
      profile_image_id {SecureRandom.alphanumeric}
    end
  end
end
