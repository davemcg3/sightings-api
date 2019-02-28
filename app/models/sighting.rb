class Sighting < ApplicationRecord
  belongs_to :subject
  belongs_to :subtype
  belongs_to :user, optional: true

  validates :zipcode, presence: true

  class << self
    def subtype(find_by_subtype)
      subtype = Subtype.find_by_name(find_by_subtype)
      raise ActiveRecord::RecordNotFound unless subtype
      where(subtype: subtype.id)
    end

    def zipcode(zip)
      where(zipcode: zip)
    end

    def start_date(date)
      where(created_at: date..Time.zone.now)
    end

    def end_date(date)
      where(created_at: 5.years.ago..date)
    end

    def arrangement(column, direction)
      order("#{column}": direction)
    end
  end
end
