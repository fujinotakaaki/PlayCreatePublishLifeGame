FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "example#{n}@user.com" }
    password { SecureRandom.alphanumeric }
    password_confirmation { password }
    confirmed_at { Time.zone.now }
    name {Faker::Name.name}
  end
end
