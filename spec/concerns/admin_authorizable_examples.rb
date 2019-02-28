require 'rails_helper'

shared_examples_for "admin_authorizable" do
  let(:controller) { described_class.new } # the class that includes the concern

  let(:user) {
    FactoryBot.create(:user)
  }

  let(:admin) {
    FactoryBot.create(:user, admin: :admin)
  }

  def inflect_model_from_controller
    model = described_class.to_s.split('::').last
    model.slice!('Controller')
    model = model.singularize
    return model.downcase.to_sym, model.titleize.constantize
  end

  def instantiate_model(with_user=user)
    model_sym, model_constant = inflect_model_from_controller
    if model_constant.new.respond_to? :user
      if model_constant.new.respond_to? :user=
        return FactoryBot.create(model_sym, user: with_user)
      else
        return user
      end
    else
      FactoryBot.create(model_sym)
    end
  end

  it "authorizes anonymous read actions" do
    expect(controller.authorize!(:read)).to be_truthy
  end

  it "authorizes admin activity" do
    allow(controller).to receive(:current_user).and_return(admin)

    expect(controller.authorize!(:update)).to be_truthy
  end

  it "authorizes users to adjust instances they own" do
    instance = instantiate_model
    skip "model can't be owned" unless instance.respond_to? :user
    allow(controller).to receive(:current_user).and_return(user)

    expect(controller.authorize!(:update, instance)).to be_truthy
  end

  it "raises forbidden errors when not authorized" do
    expect{controller.authorize!(:update)}.to raise_error NotPermittedException
  end

  it "rescues from NotPermittedException by rendering forbidden error" do
    instance = instantiate_model

    put :update, params: {id: instance.to_param}, session: {}
    expect(response).to have_http_status(:forbidden)
    expect(response.content_type).to eq('application/json')
  end
end
