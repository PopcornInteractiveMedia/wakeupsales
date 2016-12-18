class CreateUserLabels < ActiveRecord::Migration
  def change
    create_table :user_labels do |t|
      t.references :organization
      t.references :user
      t.string :name
      t.string :color

      t.timestamps
    end
    add_index :user_labels, :organization_id
    add_index :user_labels, :user_id
  end
end
