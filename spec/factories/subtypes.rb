FactoryBot.define do
  factory :subtype do
    name { "MyString" }
    subject { FactoryBot.create(:subject) }
    parent { nil }
  end
end
