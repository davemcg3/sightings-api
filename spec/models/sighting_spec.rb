require 'rails_helper'

RSpec.describe Sighting, type: :model do
  it { should belong_to(:subject) }
  it { should belong_to(:subtype) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:zipcode) }

  describe "#scopes" do
    describe "#subtype" do
      context "when a subtype is not found" do
        it "raises an ActiveRecord RecordNotFound exception" do
          expect{Sighting.subtype(:non_existent)}.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when a subtype is found" do
        it "scopes down to sightings of that subtype" do
          last_subtype = nil
          %w(one two).each do |subtype|
            last_subtype = FactoryBot.create(:subtype, name: subtype)
            FactoryBot.create(:sighting, subtype: last_subtype)
          end

          scoped = Sighting.subtype("two")

          expect(scoped.length).to eq(1)
          expect(scoped.first.subtype_id).to eq(last_subtype.id)
        end
      end
    end

    describe "#zipcode" do
      it "scopes down to sightings in that zipcode" do
        (1..2).each do |zipcode|
          FactoryBot.create :sighting, zipcode: zipcode
        end

        scoped = Sighting.zipcode(2)

        expect(scoped.length).to eq(1)
        expect(scoped.first.zipcode).to eq(2)
      end
    end

    describe "#start_date" do
      it "scopes down to sightings on the start date or later" do
        days_to_start = 3
        days_to_start.times do
          FactoryBot.create :sighting, created_at: days_to_start.days.ago.beginning_of_day
          days_to_start -= 1
        end

        scoped = Sighting.start_date(2.days.ago.beginning_of_day)

        expect(scoped.length).to eq(2)
      end
    end

    describe "#end_date" do
      it "scopes down to sightings earlier than the end date" do
        days_to_start = 3
        days_to_start.times do
          FactoryBot.create :sighting, created_at: days_to_start.days.ago.beginning_of_day
          days_to_start -= 1
        end

        scoped = Sighting.end_date(2.days.ago.beginning_of_day)

        expect(scoped.length).to eq(2)
      end
    end

    describe "#arrangement" do
      # TODO: Add more order by tests for all the columns
      it "orders by column in the desired direction" do
        count = 1
        3.times do
          FactoryBot.create(:sighting, number_sighted: count)
          count += 1
        end

        expect(Sighting.arrangement(:number_sighted, :desc).first.number_sighted).to eq(3)
        expect(Sighting.arrangement(:number_sighted, :asc).first.number_sighted).to eq(1)
      end
    end
  end
end
