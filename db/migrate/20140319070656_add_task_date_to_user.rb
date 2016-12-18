class AddTaskDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :task_date, :datetime
  end
end
