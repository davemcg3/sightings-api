class SightingSerializer < ActiveModel::Serializer
  attributes :id, :zipcode, :notes, :number_sighted, :created_at
  belongs_to :subject
  belongs_to :subtype
  belongs_to :user

  def subject
    object.subject.name
  end

  def subtype
    object.subtype.name
  end

  def user
    object.user.present? ? object.user.display_name : "anonymous"
  end
end
