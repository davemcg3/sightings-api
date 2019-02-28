require 'rails_helper'

RSpec.describe DecodeAuthenticationCommand do
  let(:user) { FactoryBot.create(:user, email: "test@example.org", password: "1234") }

  def token(id=user.id, exp=(24.hours.from_now.to_i))
    JwtService.encode({'user_id': id, exp: exp })
  end

  context 'with a valid Authorization header' do
    it 'returns a user' do
      decoded = DecodeAuthenticationCommand.call({"Authorization": "bearer #{token}"}.stringify_keys)

      expect(decoded.result).to eq(user)
    end
  end

  context 'without a valid Authorization header' do
    it 'returns nil if there is no Authorization header' do
      decoded = DecodeAuthenticationCommand.call({})

      expect(decoded.result).to be_nil
      expect(decoded.errors[:token].first).to eq("Token Missing")
    end

    it 'returns nil if there is an invalid token' do
      decoded = DecodeAuthenticationCommand.call({"Authorization": "bearer #{token(user.id + 1)}"}.stringify_keys)

      expect(decoded.result).to be_nil
      expect(decoded.errors[:token].first).to eq("Token Invalid")
    end

    it 'returns nil if there is an expired token' do
      decoded = DecodeAuthenticationCommand.call({"Authorization": "bearer #{token(user.id, 24.hours.ago)}"}.stringify_keys)

      expect(decoded.result).to be_nil
      expect(decoded.errors[:token].first).to eq("Token Expired")
    end
  end
end
