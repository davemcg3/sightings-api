require 'rails_helper'

RSpec.describe JwtService do
  subject { described_class }

  let(:payload) { { 'one' => 'two'} }
  let(:token) { JwtService.encode(payload) }
  let(:expired_token) { JwtService.encode({exp: 1.day.ago}) }

  describe '.encode' do
    it { expect(subject.encode(payload)).to eq(token) }
  end

  describe '.decode' do
    it { expect(subject.decode(token)).to eq(payload)}
    it { expect(subject.decode(expired_token)).to be_nil}
  end
end
