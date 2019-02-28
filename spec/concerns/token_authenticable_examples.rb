require 'rails_helper'
require 'ostruct'

shared_examples_for "token_authenticable" do
  let(:controller) { described_class.new } # the class that includes the concern

  let(:user) {
    FactoryBot.create(:user)
  }

  def inflect_model_from_controller
    model = described_class.to_s.split('::').last
    model.slice!('Controller')
    model = model.singularize
    return model.downcase.to_sym, model.titleize.constantize
  end

  it "exposes a current_user attribute" do
    expect(controller).to respond_to(:current_user)
  end

  it "authenticates a user from a token" do
    allow(controller).to receive(:request).and_return(OpenStruct.new({ headers: {"Authorization": "Bearer #{JwtService.encode({user_id: user.id})}"}.stringify_keys}))

    controller.send(:authenticate_user)
    expect(controller.current_user).to eq(user)
  end

  it "does not raise a NotAuthorizedException" do
    model_sym, model_constant = inflect_model_from_controller
    instance = FactoryBot.create(model_sym)

    put :update, params: {id: instance.id.to_param}, session: {}
    expect(response).not_to have_http_status(:unauthorized)
    expect(response.content_type).to eq('application/json')
  end
end
