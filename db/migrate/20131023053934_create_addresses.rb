class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :organization
      t.string :address_type
      t.text :address
      t.references :country
      t.string :state
      t.string :city
      t.string :zipcode
      t.string :addressable_type
      t.integer :addressable_id

      t.timestamps
    end
    add_index :addresses, :organization_id
    add_index :addresses, :country_id
  end
end
