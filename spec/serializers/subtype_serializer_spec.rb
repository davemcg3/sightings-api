require 'rails_helper'

RSpec.describe SubtypeSerializer, type: :serializer do
  let(:subtype) { FactoryBot.create(:subtype) }
  let(:serializer) { described_class.new(subtype) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  let(:subject) { JSON.parse(serialization.to_json) }

  it 'has an id that matches' do
    expect(subject['data']['id']).to eql(subtype.id.to_s)
  end

  it 'has a name that matches' do
    expect(subject['data']['attributes']['name']).to eql(subtype.name)
  end

  it 'has a subject that matches' do
    expect(subject['data']['relationships']['subject']['data']).to eql(subtype.subject.name)
  end
end
