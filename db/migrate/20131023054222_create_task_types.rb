class CreateTaskTypes < ActiveRecord::Migration
  def change
    create_table :task_types do |t|
      t.references :organization
      t.string :name

      t.timestamps
    end
    add_index :task_types, :organization_id
  end
end
