class SubtypeSerializer < ActiveModel::Serializer
  # change subject to relationship
  attributes :id, :name
  belongs_to :subject

  def subject
    object.subject.name
  end
end
