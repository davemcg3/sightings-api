class Subtype < ApplicationRecord
  belongs_to :subject
  belongs_to :parent, class_name: "Subtype", optional: true
  has_many :children, class_name: "Subtype", :foreign_key => 'parent_id'

  validates :name, presence: true
end

