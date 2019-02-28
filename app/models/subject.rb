class Subject < ApplicationRecord
  validates :name, presence: true

  has_many :subtypes
end
