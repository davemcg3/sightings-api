require 'rails_helper'

RSpec.describe "Users", type: :request do
  let!(:user) {
    FactoryBot.create(:user)
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
    it 'can only list or show users' do
      # index
      get '/v1/users'
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(0)

      # show
      get "/v1/users/#{user.id}"
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["attributes"]["display_name"]).to eq(user.display_name)

      # update
      name = 'grizzly bear'
      patch "/v1/users/#{user.id}", params: {user: {display_name: name}}
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # update
      name = 'kodiak bear'
      put "/v1/users/#{user.id}", params: {user: {display_name: name}}
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))

      # destroy
      delete "/v1/users/#{user.id}"
      expect(JSON.parse(response.body)["error"]).to eq(I18n.t('admin_authorizable_concern.not_permitted'))
    end
  end

  context 'with a standard user' do
    it 'can only list or show users' do
      # index
      get '/v1/users', params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first["id"]).to eq(user.id.to_s)
      expect(parsed_response.first["attributes"]["display-name"]).to eq(user.display_name)

      # show
      get "/v1/users/#{user.id}", params: nil, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]

      # update
      name = 'grizzly bear'
      patch "/v1/users/#{user.id}", params: {user: {display_name: name}}, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(user.id.to_s)
      expect(parsed_response["attributes"]["display-name"]).to eq(name)

      # update
      name = 'kodiak bear'
      put "/v1/users/#{user.id}", params: {user: {display_name: name}}, headers: headers(user)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to eq(user.id.to_s)
      expect(parsed_response["attributes"]["display-name"]).to eq(name)

      # destroy
      delete "/v1/users/#{user.id}", params: nil, headers: headers(user)
      expect(response.status).to eq(204) # no content
    end
  end

  context 'with an admin user' do
    it 'can list, show, create, update (patch), update (put), and destroy' do
      # index
      get '/v1/users', params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response.length).to eq(2)
      expect(parsed_response.first["id"]).to eq(user.id.to_s)
      expect(parsed_response.first["attributes"]["display-name"]).to eq(admin.display_name)
      expect(parsed_response.second["id"]).to eq(admin.id.to_s)
      expect(parsed_response.second["attributes"]["display-name"]).to eq(admin.display_name)

      # show
      get "/v1/users/#{user.id}", params: nil, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["attributes"]["display_name"]).to eq(user.display_name)

      # update
      name = 'grizzly bear'
      patch "/v1/users/#{user.id}", params: {user: {display_name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["display-name"]).to eq(name)

      # update
      name = 'kodiak bear'
      put "/v1/users/#{user.id}", params: {user: {display_name: name}}, headers: headers(admin)
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["id"]).to be_present
      expect(parsed_response["attributes"]["display-name"]).to eq(name)

      # destroy
      delete "/v1/users/#{user.id}", params: nil, headers: headers(admin)
      expect(response.status).to eq(204) # no content
    end
  end
end
