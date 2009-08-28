class ActivitySectorTranslation < ActiveRecord::Base
  belongs_to :activity_sector
  validates_uniqueness_of :local, :scope => :activity_sector_id
  validates_presence_of :name


end
