class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.references :organization
      t.string :title
      t.references :priority_type
      t.integer :assigned_to
      t.references :contact
      t.string :tags
      t.float :amount
      t.integer :probability
      t.integer :attempts
      t.boolean :is_public
      t.integer :initiated_by

      t.timestamps
    end
    add_index :deals, :organization_id
    add_index :deals, :priority_type_id
  end
  
end
