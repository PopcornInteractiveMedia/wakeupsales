class AddTaskTypeToTempLead < ActiveRecord::Migration
  def change
    add_column :temp_leads, :task_type, :string
  end
end
