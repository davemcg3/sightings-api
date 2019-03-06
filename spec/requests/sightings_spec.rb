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


  context 'when not searching' do
    let!(:sighting) {
      FactoryBot.create(:sighting)
    }

    let(:user) {
      FactoryBot.create(:user)
    }

    let(:admin) {
      FactoryBot.create(:user, admin: :admin)
    }

    def headers(with_user)
      {'Authorization': "Bearer #{JwtService.encode({user_id: with_user.id})}"}.stringify_keys
    end

    context 'without a user' do
      it 'can only list, show, and create anonymous sightings' do
        # index
        get '/v1/sightings'
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response.length).to eq(1)
        expect(parsed_response.first["id"]).to eq(sighting.id.to_s)
        expect(parsed_response.first["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # show
        get "/v1/sightings/#{sighting.id}"
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to eq(sighting.id.to_s)
        expect(parsed_response["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # create
        zipcode = 12345
        post "/v1/sightings", params: {sighting: {subject: Subtype.first.subject.name, subtype: Subtype.first.name, zipcode: zipcode}}
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to be_present
        expect(parsed_response["attributes"]["zipcode"]).to eq(zipcode)
        expect(parsed_response["relationships"]["user"]["data"]).to eq("anonymous")

        # update
        zipcode = 54321
        patch "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

        # update
        zipcode = 54321
        put "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

        # destroy
        delete "/v1/sightings/#{sighting.id}"
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
      end
    end

    context 'with a standard user' do
      it 'can only list or show sightings' do
        # index
        get '/v1/sightings', params: nil, headers: headers(user)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response.length).to eq(1)
        expect(parsed_response.first["id"]).to eq(sighting.id.to_s)
        expect(parsed_response.first["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # show
        get "/v1/sightings/#{sighting.id}", params: nil, headers: headers(user)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to eq(sighting.id.to_s)
        expect(parsed_response["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # create
        zipcode = 12345
        post "/v1/sightings", params: {sighting: {subject: Subtype.first.subject.name, subtype: Subtype.first.name, zipcode: zipcode}}, headers: headers(user)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to be_present
        expect(parsed_response["attributes"]["zipcode"]).to eq(zipcode)
        expect(parsed_response["relationships"]["user"]["data"]).to eq(user.display_name)

        # update
        zipcode = 54321
        patch "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}, headers: headers(user)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

        # update
        zipcode = 54321
        put "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}, headers: headers(user)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

        # destroy
        delete "/v1/sightings/#{sighting.id}", params: nil, headers: headers(user)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
      end
    end

    context 'with an admin user' do
      it 'can list, show, create, update (patch), update (put), and destroy' do
        # index
        get '/v1/sightings', params: nil, headers: headers(admin)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response.length).to eq(1)
        expect(parsed_response.first["id"]).to eq(sighting.id.to_s)
        expect(parsed_response.first["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # show
        get "/v1/sightings/#{sighting.id}", params: nil, headers: headers(admin)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to eq(sighting.id.to_s)
        expect(parsed_response["attributes"]["zipcode"]).to eq(sighting.zipcode)

        # create
        zipcode = 54321
        post "/v1/sightings", params: {sighting: {subject: Subtype.first.subject.name, subtype: Subtype.first.name, zipcode: zipcode}}, headers: headers(admin)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to be_present
        expect(parsed_response["attributes"]["zipcode"]).to eq(zipcode)
        expect(parsed_response["relationships"]["user"]["data"]).to eq(admin.display_name)

        # update
        zipcode = 54321
        patch "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}, headers: headers(admin)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to be_present
        expect(parsed_response["attributes"]["zipcode"]).to eq(zipcode)

        # update
        zipcode = 54321
        put "/v1/sightings/#{sighting.id}", params: {sighting: {zipcode: zipcode}}, headers: headers(admin)
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response["id"]).to be_present
        expect(parsed_response["attributes"]["zipcode"]).to eq(zipcode)

        # destroy
        delete "/v1/sightings/#{sighting.id}", params: nil, headers: headers(admin)
        expect(response.status).to eq(204) # no content
      end
    end
  end
end
