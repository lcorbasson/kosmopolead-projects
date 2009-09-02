class ActivitySector < ActiveRecord::Base
  has_many :activity_sector_translations
  validates_presence_of :identifier
  validates_uniqueness_of :identifier

  after_create :add_activity_sector_translation

  attr_accessor :local, :description, :name

  private

  def add_activity_sector_translation
    activity_sector_translations.create :local => local, :description => description, :name => name
  end
end
