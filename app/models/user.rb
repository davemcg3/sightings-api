class User < ApplicationRecord
  enum admin: [:admin, :almost_admin, :standard]

  has_secure_password
  validates :email, presence: true

  has_many :sightings

  def user
    self
  end
end
