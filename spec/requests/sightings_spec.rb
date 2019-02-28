require 'rails_helper'

RSpec.describe "Sightings", type: :request do
  context 'with an unregistered user' do
    before :all do
      subject = FactoryBot.create(:subject, name: :bear)
      %w(black brown polar).each {|bear| FactoryBot.create(:subtype, name: bear.titleize, subject: subject)}
    end

    after :all do
      Subtype.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!('Subtypes')
      Subject.destroy_all
      ActiveRecord::Base.connection.reset_pk_sequence!('Subjects')
    end

    it 'can post anonymous sighting' do
      post '/sighting', params: { sighting: { subject: "bear", subtype: "Brown", notes: 'It was a big one!', zipcode: '90210', number_sighted: 3} }

      parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]
      expect(parsed_response[:id]).to be_truthy
      expect(parsed_response[:attributes][:notes]).to eq('It was a big one!')
      expect(parsed_response[:attributes][:zipcode]).to eq(90210)
      expect(parsed_response[:attributes]["number-sighted"]).to eq(3)
      expect(parsed_response[:relationships][:subtype][:data]).to eq("Brown")
      expect(parsed_response[:relationships][:subject][:data]).to eq("bear")
      expect(parsed_response[:relationships][:user][:data]).to eq("anonymous")
    end

    context 'when searching all sightings' do
      before do
        days_ago_to_start = 10
        zipcode = 12345
        number_sighted = 3
        Subtype.all.each do |subtype|
          FactoryBot.create(:sighting, subject: Subject.first, subtype: subtype, created_at: days_ago_to_start.days.ago, zipcode: zipcode, number_sighted: number_sighted)
          days_ago_to_start -= 1
          zipcode += 10000
          number_sighted += 1
        end
      end

      it 'returns an unfiltered list' do
        get '/sighting/search'

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.length).to eq(3)
      end

      it 'can filter by start date' do
        get '/sighting/search' , params: { sighting:{ start_date: 9.days.ago } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.length).to eq(2)
      end

      it 'can filter by end date' do
        get '/sighting/search', params: { sighting: { end_date: 10.days.ago } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.length).to eq(1)
      end

      it 'can filter by bear type' do
        get '/sighting/search', params: { sighting: { subtype: "Polar" } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.length).to eq(1)

      end

      it 'can filter by zip code' do
        get '/sighting/search', params: { sighting: { zipcode: 22345 } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.length).to eq(1)

      end

      it 'sorts by created at ascending by default' do
        get '/sighting/search'

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.pluck(:id).map!{|id| id.to_i}).to eq(Sighting.last(3).pluck(:id).sort)
      end

      it 'can also sort descending' do
        get '/sighting/search', params: { sighting: { sort_order: "desc" } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.pluck(:id).map!{|id| id.to_i}).to eq(Sighting.last(3).pluck(:id).sort.reverse)
      end

      it 'can sort by num_bears' do
        get '/sighting/search', params: { sighting: { sort: "number_sighted", sort_order: "desc" } }

        parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

        expect(parsed_response.pluck(:id).map!{|id| id.to_i}).to eq(Sighting.last(3).pluck(:id).sort.reverse)
      end
    end

    it 'can retrieve single sighting' do
      sighting = FactoryBot.create(:sighting, subject: Subject.first, subtype: Subtype.first, zipcode: 12345, number_sighted: 5)

      get "/sighting/#{sighting.id}"

      parsed_response = HashWithIndifferentAccess.new(JSON.parse(response.body))[:data]

      expect(parsed_response[:id]).to eq(sighting.id.to_s)
    end
  end
end
