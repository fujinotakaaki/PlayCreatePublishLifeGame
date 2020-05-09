FactoryBot.define do
  factory :user do
    password = SecureRandom.alphanumeric
    sequence(:email) { |n| "example#{n}@user.com" }
    password { password }
    password_confirmation { password }
    confirmed_at { Time.zone.now }
    sequence(:name) { |n| "example_user'#{n}" }
  end
end
