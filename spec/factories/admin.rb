FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@user.com" }
    password { SecureRandom.alphanumeric }
    password_confirmation { password }
  end
end
