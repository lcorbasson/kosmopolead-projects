class ActivitySectorTranslation < ActiveRecord::Base
  belongs_to :activity_sector
  validates_uniqueness_of :local, :scope => :activity_sector_id


end
