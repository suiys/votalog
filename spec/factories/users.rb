FactoryBot.define do
  factory :user do
    name { "testuser1" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "test12345" }
  end
end
