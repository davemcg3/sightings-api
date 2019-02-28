FactoryBot.define do
  factory :sighting do
    subject { FactoryBot.create(:subject) }
    subtype { FactoryBot.create(:subtype, subject: subject) }
    zipcode { 1 }
    notes { "MyText" }
    number_sighted { 1 }
  end
end
