require 'rails_helper'

RSpec.describe SubjectSerializer, type: :serializer do
  let(:model) { FactoryBot.create(:subject) }
  let(:serializer) { described_class.new(model) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  let(:subject) { JSON.parse(serialization.to_json) }

  it 'has an id that matches' do
    expect(subject['data']['id']).to eql(model.id.to_s)
  end

  it 'has a name that matches' do
    expect(subject['data']['attributes']['name']).to eql(model.name)
  end
end
