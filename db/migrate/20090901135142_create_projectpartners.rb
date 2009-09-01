class CreateProjectpartners < ActiveRecord::Migration
  def self.up
    create_table :projectpartners do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :projectpartners
  end
end
