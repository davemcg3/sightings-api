require 'rails_helper'

RSpec.describe "Subtypes", type: :request do
  let!(:subtype) {
    FactoryBot.create(:subtype, name: :bear)
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
    it 'can only list or show subtypes' do
      # index
      get '/v1/subtypes'
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subtype.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subtype.name)

      # show
      get "/v1/subtypes/#{subtype.id}"
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subtype.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subtype.name)

      # create
      name = 'brown bear'
      post "/v1/subtypes", params: {subtype: {name: name, subject_id: subtype.subject.id}}
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      name = 'grizzly bear'
      patch "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      name = 'kodiak bear'
      put "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # destroy
      delete "/v1/subtypes/#{subtype.id}"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
    end
  end

  context 'with a standard user' do
    it 'can only list or show subtypes' do
      # index
      get '/v1/subtypes', params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subtype.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subtype.name)

      # show
      get "/v1/subtypes/#{subtype.id}", params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subtype.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subtype.name)

      # create
      name = 'brown bear'
      post "/v1/subtypes", params: {subtype: {name: name, subject_id: subtype.subject.id}}, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      name = 'grizzly bear'
      patch "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      name = 'kodiak bear'
      put "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # destroy
      delete "/v1/subtypes/#{subtype.id}", params: nil, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
    end
  end

  context 'with an admin user' do
    it 'can list, show, create, update (patch), update (put), and destroy' do
      # index
      get '/v1/subtypes', params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subtype.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subtype.name)

      # show
      get "/v1/subtypes/#{subtype.id}", params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subtype.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subtype.name)

      # create
      name = 'brown bear'
      post "/v1/subtypes", params: {subtype: {name: name, subject_id: subtype.subject.id}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # update
      name = 'grizzly bear'
      patch "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # update
      name = 'kodiak bear'
      put "/v1/subtypes/#{subtype.id}", params: {subtype: {name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # destroy
      delete "/v1/subtypes/#{subtype.id}", params: nil, headers: headers(admin)
      expect(response.status).to eq(204) # no content
    end
  end
end
