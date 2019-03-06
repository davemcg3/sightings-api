require 'rails_helper'

RSpec.describe User, type: :model do
  it { should define_enum_for(:admin).with_values([:admin, :almost_admin, :standard])}
  it { should have_secure_password }
  it { should validate_presence_of(:email) }
  it { should have_many(:sightings) }
end
