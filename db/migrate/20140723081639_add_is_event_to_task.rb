class AddIsEventToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :is_event, :boolean, null: false, default: false
    add_column :tasks, :event_end_date, :datetime
  end
end
