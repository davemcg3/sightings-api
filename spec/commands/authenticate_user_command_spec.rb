require 'rails_helper'

RSpec.describe AuthenticateUserCommand do
  let(:user) { FactoryBot.create(:user, email: "test@example.org", password: "1234") }

  context 'with a valid email and password' do
    it 'authenticates' do
      authenticate = AuthenticateUserCommand.call(user.email, user.password)

      expect(authenticate.success?).to eq(true)
      expect(authenticate.result).to eq(JwtService.encode({user_id: user.id, exp: 24.hours.from_now.to_i}))
    end
  end

  context 'with a bad password' do
    it 'fails to authenticate' do
      authenticate = AuthenticateUserCommand.call(user.email, '4321')

      expect(authenticate.success?).to eq(false)
      expect(authenticate.result).to eq(nil)
      expect(authenticate.errors.messages[:base].first).to eq(I18n.t('authenticate_user_command.invalid_credentials'))
    end
  end
end
