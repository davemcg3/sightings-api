require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:user) { FactoryBot.create(:user) }
  let(:serializer) { described_class.new(user) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  let(:subject) { JSON.parse(serialization.to_json) }

  it 'has an id that matches' do
    expect(subject['data']['id']).to eql(user.id.to_s)
  end

  it 'has a name that matches' do
    expect(subject['data']['attributes']['display-name']).to eql(user.display_name)
  end
end
