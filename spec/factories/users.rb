FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    display_name { "MyString" }
    admin { 2 }
  end
end
