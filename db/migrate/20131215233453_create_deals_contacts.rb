class CreateDealsContacts < ActiveRecord::Migration
  def change
    create_table :deals_contacts do |t|
      t.integer :organization_id
      t.integer :deal_id
      t.string  :contactable_type
      t.integer :contactable_id

      t.timestamps
    end
  end
end
