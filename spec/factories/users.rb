FactoryBot.define do
  factory :user do
    provider { "MyString" }
    uid { "MyString" }
    name { "MyString" }
    token { "MyString" }
    secret { "MyString" }
    avatar { "MyString" }
    automated { false }
  end
end
