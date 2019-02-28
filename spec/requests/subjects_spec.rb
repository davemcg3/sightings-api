require 'rails_helper'

RSpec.describe "Subjects", type: :request do
  let!(:subject) {
    FactoryBot.create(:subject, name: :bear)
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
    it 'can only list or show subjects' do
      # index
      get '/v1/subjects'
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subject.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subject.name)

      # show
      get "/v1/subjects/#{subject.id}"
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subject.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subject.name)

      # create
      post "/v1/subjects"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      patch "/v1/subjects/#{subject.id}"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      put "/v1/subjects/#{subject.id}"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # destroy
      delete "/v1/subjects/#{subject.id}"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
    end
  end

  context 'with a standard user' do
    it 'can only list or show subjects' do
      # index
      get '/v1/subjects', params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subject.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subject.name)

      # show
      get "/v1/subjects/#{subject.id}", params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subject.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subject.name)

      # create
      post "/v1/subjects", params: nil, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      patch "/v1/subjects/#{subject.id}", params: nil, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      put "/v1/subjects/#{subject.id}", params: nil, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # destroy
      delete "/v1/subjects/#{subject.id}", params: nil, headers: headers(user)
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
    end
  end

  context 'with an admin user' do
    it 'can list, show, create, update (patch), update (put), and destroy' do
      # index
      get '/v1/subjects', params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(subject.id.to_s)
      expect(parsed_response.first["attributes"]["name"]).to eq(subject.name)

      # show
      get "/v1/subjects/#{subject.id}", params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(subject.id.to_s)
      expect(parsed_response["attributes"]["name"]).to eq(subject.name)

      # create
      name = 'brown bear'
      post "/v1/subjects", params: {subject: {name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # update
      name = 'grizzly bear'
      patch "/v1/subjects/#{subject.id}", params: {subject: {name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # update
      name = 'kodiak bear'
      put "/v1/subjects/#{subject.id}", params: {subject: {name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["name"]).to eq(name)

      # destroy
      delete "/v1/subjects/#{subject.id}", params: nil, headers: headers(admin)
      expect(response.status).to eq(204) # no content
    end
  end
end
