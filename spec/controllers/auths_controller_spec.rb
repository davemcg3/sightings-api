require 'rails_helper'

RSpec.describe V1::AuthsController, type: :controller do
  let(:valid_params) {
    {
      email: "123@abc.com",
      password: "1234",
      display_name: "john"
    }
  }

  let(:invalid_attributes) {
    {
        email: nil,
        password: nil,
        name: nil
    }
  }

  let(:authenticate_user_command) {
    spy('AuthenticateUserCommand')
  }

  describe "POST #create" do
    context "with valid params" do
      before do
        allow(authenticate_user_command).to receive(:success?).and_return(true)
        allow(authenticate_user_command).to receive(:result).and_return(123)
        stub_const('AuthenticateUserCommand', authenticate_user_command)
      end

      it "calls for the creation of a new token" do
        post :create, params: {auth: valid_params}#, session: valid_session
        expect(authenticate_user_command).to have_received(:call)
      end

      it "renders a JSON response with the new token" do
        post :create, params: {auth: valid_params}#, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["token"]).to eq(123)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new sighting" do
        allow(authenticate_user_command).to receive(:success?).and_return(false)
        allow(authenticate_user_command).to receive(:errors).and_return("Invalid Credentials")
        stub_const('AuthenticateUserCommand', authenticate_user_command)

        post :create, params: {auth: invalid_attributes}#, session: valid_session
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["error"]).to eq("Invalid Credentials")
      end
    end
  end

  describe "POST #register" do
    context "with valid params" do
      it "calls for the creation of a new user" do
        expect{
          post :register, params: {auth: valid_params}#, session: valid_session
        }.to change{User.count}.by(1)
      end

      it "renders a JSON response with the new user" do
        post :register, params: {auth: valid_params}#, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["data"]["type"]).to eq("users")
        expect(JSON.parse(response.body)["data"]["attributes"]["email"]).to eq(valid_params[:email])
        expect(JSON.parse(response.body)["data"]["attributes"]["display-name"]).to eq(valid_params[:display_name])
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new user" do
        expected = {
          password: ["can't be blank"],
          email: ["can't be blank"]
        }
        post :register, params: {auth: invalid_attributes}#, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to eq(JSON.generate(expected))
      end
    end
  end
end
