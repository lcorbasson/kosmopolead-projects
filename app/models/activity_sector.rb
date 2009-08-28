class ActivitySector < ActiveRecord::Base
  has_many :activity_sector_translations
  validates_presence_of :identifier
end
