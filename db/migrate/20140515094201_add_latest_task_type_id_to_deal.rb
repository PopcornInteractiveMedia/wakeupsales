class AddLatestTaskTypeIdToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :latest_task_type_id, :integer
  end
end
