class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.references :organization
      t.string :phone_no
      t.string :extension
      t.string :phone_type
      t.string :phoneble_type
      t.integer :phoneble_id

      t.timestamps
    end
    add_index :phones, :organization_id
  end
end
