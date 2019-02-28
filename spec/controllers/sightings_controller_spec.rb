require 'rails_helper'
require Rails.root.join "spec/concerns/admin_authorizable_examples.rb"
require Rails.root.join "spec/concerns/token_authenticable_examples.rb"

RSpec.describe V1::SightingsController, type: :controller do
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

  let(:user) {
    FactoryBot.create(:user)
  }

  let(:admin) {
    FactoryBot.create(:user, admin: :admin)
  }

  # This should return the minimal set of attributes required to create a valid
  # Sighting. As you add validations to Sighting, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      subject: Subtype.first.subject,
      subtype: Subtype.first,
      zipcode: 12345
    }
  }

  let(:valid_params) {
    {
      subject: Subtype.first.subject.name,
      subtype: Subtype.first.name,
      zipcode: 12345
    }
  }

  let(:invalid_attributes) {
    { zipcode: nil }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SightingsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  it_behaves_like "admin_authorizable"
  it_behaves_like "token_authenticable"

  describe "GET #index" do
    it "returns a success response" do
      sighting = Sighting.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      sighting = Sighting.create! valid_attributes
      get :show, params: {id: sighting.to_param}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Sighting" do
        expect {
          post :create, params: {sighting: valid_params}#, session: valid_session
        }.to change(Sighting, :count).by(1)
      end

      it "renders a JSON response with the new sighting" do
        post :create, params: {sighting: valid_params}, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["data"]["id"]).to eq(Sighting.last.id.to_s)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new sighting" do
        post :create, params: {sighting: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { zipcode: 54321 }
      }

      context "with an object owned by the user" do
        it "updates the requested sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: user)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          sighting.reload
          expect(sighting.zipcode).to eq(54321)
        end

        it "renders a JSON response with the sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: user)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
        end
      end

      context "with an admin user" do
        it "updates the requested sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: user)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: admin.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          sighting.reload
          expect(sighting.zipcode).to eq(54321)
        end

        it "renders a JSON response with the sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: user)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: admin.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('application/json')
        end
      end

      context "with an object not owned by the user" do
        it "does not update the requested sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: admin)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          sighting.reload
          expect(sighting.zipcode).to eq(12345)
        end

        it "renders a JSON response with the sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: admin)
          request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          expect(response).to have_http_status(:forbidden)
          expect(response.content_type).to eq('application/json')
        end
      end

      context "when there is no user" do
        it "does not update the requested sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: admin)

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          sighting.reload
          expect(sighting.zipcode).to eq(12345)
        end

        it "renders a JSON response with the sighting" do
          sighting = Sighting.create! valid_attributes.merge(user: admin)

          put :update, params: {id: sighting.to_param, sighting: new_attributes}, session: valid_session
          expect(response).to have_http_status(:forbidden)
          expect(response.content_type).to eq('application/json')
        end
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the sighting" do
        sighting = Sighting.create! valid_attributes.merge(user: user)
        request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"

        put :update, params: {id: sighting.to_param, sighting: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    context "with an object owned by the user" do
      it "destroys the requested sighting" do
        sighting = Sighting.create! valid_attributes.merge(user: user)
        request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"
        expect {
          delete :destroy, params: {id: sighting.to_param}, session: valid_session
        }.to change(Sighting, :count).by(-1)
      end
    end

    context "with an admin user" do
      it "destroys the requested sighting" do
        sighting = Sighting.create! valid_attributes.merge(user: user)
        request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: admin.id})}"
        expect {
          delete :destroy, params: {id: sighting.to_param}, session: valid_session
        }.to change(Sighting, :count).by(-1)
      end
    end

    context "with an object not owned by the user" do
      it "does not destroy the requested sighting" do
        sighting = Sighting.create! valid_attributes.merge(user: admin)
        request.headers['Authorization'] = "Bearer #{JwtService.encode({user_id: user.id})}"
        expect {
          delete :destroy, params: {id: sighting.to_param}, session: valid_session
        }.not_to change(Sighting, :count)
      end
    end

    context "when there is no user" do
      it "does not destroy the requested sighting" do
        sighting = Sighting.create! valid_attributes.merge(user: admin)
        expect {
          delete :destroy, params: {id: sighting.to_param}, session: valid_session
        }.not_to change(Sighting, :count)
      end
    end
  end
end
