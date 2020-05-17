FactoryBot.define do
  factory :favorite do
    association :user, factory: :user
    association :pattern, factory: :pattern
  end
end
