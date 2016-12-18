class AddTaskNoteToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :task_note, :text
  end
end
