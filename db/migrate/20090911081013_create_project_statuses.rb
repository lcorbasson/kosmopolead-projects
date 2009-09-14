class CreateProjectStatuses < ActiveRecord::Migration
  def self.up
    create_table :project_statuses, :force => true do |t|
      t.string   :status_label
      t.boolean  :is_default
      t.integer  :position
      t.timestamps
    end
  end

  def self.down
    drop_table :project_statuses
  end
end
