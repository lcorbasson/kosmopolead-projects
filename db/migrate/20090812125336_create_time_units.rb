class CreateTimeUnits < ActiveRecord::Migration
  def self.up
     create_table :time_units do |t|
      t.string :label
      t.timestamp
    end

    ["hours", "days"].each do |unit|
      TimeUnit.create(:label=>unit)
    end
  end

  def self.down
    drop_table :time_units
  end
end
