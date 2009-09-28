class ActivitySector < ActiveRecord::Base
  has_many :activity_sector_translations,:dependent=>:destroy
  has_many :projects
  belongs_to :community
  
  validates_presence_of :identifier, :community
  validates_uniqueness_of :identifier, :scope => [:community_id]

  after_create :add_activity_sector_translation

  attr_accessor :local, :description, :name

  private

  def add_activity_sector_translation
    activity_sector_translations.create :local => local, :description => description, :name => name
  end

end
