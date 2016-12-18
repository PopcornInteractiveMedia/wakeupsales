class AddTaskableToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :mail_to, :string
    add_column :tasks, :taskable_id, :integer
    add_column :tasks, :taskable_type, :string
    add_column :tasks, :created_by, :integer
    add_column :tasks, :is_completed, :boolean, :null => false, :default => false
  end
end
