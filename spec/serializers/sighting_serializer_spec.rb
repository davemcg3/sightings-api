require 'rails_helper'

RSpec.describe SightingSerializer, type: :serializer do
  let(:sighting) { FactoryBot.build(:sighting) }
  let(:serializer) { described_class.new(sighting) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }

  let(:subject) { JSON.parse(serialization.to_json) }

  it 'has an id that matches' do
    expect(subject['id']).to eql(sighting.id)
  end

  it 'has a zipcode that matches' do
    expect(subject['data']['attributes']['zipcode']).to eql(sighting.zipcode)
  end

  it 'has a notes that matches' do
    expect(subject['data']['attributes']['notes']).to eql(sighting.notes)
  end

  it 'has a number_sighted that matches' do
    expect(subject['data']['attributes']['number-sighted']).to eql(sighting.number_sighted)
  end

  it 'has a subject relationship that matches' do
    expect(subject['data']['relationships']['subject']['data']).to eql(sighting.subject.name)
  end

  it 'has a subtype relationship that matches' do
    expect(subject['data']['relationships']['subtype']['data']).to eql(sighting.subtype.name)
  end

  it 'has a user relationship that matches' do
    expect(subject['data']['relationships']['user']['data']).to eql('anonymous')
  end
end
