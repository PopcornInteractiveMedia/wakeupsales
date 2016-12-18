class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :organization
      t.string :title
      t.references :task_type
      t.integer :assigned_to
      t.integer :priority_id
      t.integer :deal_id
      t.datetime :due_date

      t.timestamps
    end
    add_index :tasks, :organization_id
    add_index :tasks, :task_type_id
  end
end
