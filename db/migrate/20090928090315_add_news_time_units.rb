class AddNewsTimeUnits < ActiveRecord::Migration
  def self.up
    ["months", "weeks"].each do |unit|
      TimeUnit.create(:label=>unit)
    end
  end

  def self.down
  end
end
