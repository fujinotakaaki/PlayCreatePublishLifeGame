FactoryBot.define do
  factory :user do
    password = 'ExamplePassword'
    email { 'example@user.com' }
    password { password }
    password_confirmation { password }
    confirmed_at { Time.zone.now }
    name { 'example_user' }
  end
end
