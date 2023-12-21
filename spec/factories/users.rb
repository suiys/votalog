FactoryBot.define do
  factory :user do
    name { "testuser1" }
    email { "test@example.com" }
    password { "test12345" }
  end
end
