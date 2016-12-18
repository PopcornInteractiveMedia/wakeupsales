class CreateTaskPriorityTypes < ActiveRecord::Migration
  def change
    create_table :task_priority_types do |t|
      t.references :organization
      t.string :name
      t.integer :original_id

      t.timestamps
    end
    add_index :task_priority_types, :organization_id
  end
end
