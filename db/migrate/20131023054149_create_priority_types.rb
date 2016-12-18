class CreatePriorityTypes < ActiveRecord::Migration
  def change
    create_table :priority_types do |t|
      t.references :organization
      t.string :name
      t.integer :original_id

      t.timestamps
    end
    add_index :priority_types, :organization_id
  end
end
