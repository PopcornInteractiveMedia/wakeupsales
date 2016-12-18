class CreateDealStatuses < ActiveRecord::Migration
  def change
    create_table :deal_statuses do |t|
      t.references :organization
      t.string :name
      t.integer :original_id

      t.timestamps
    end
    add_index :deal_statuses, :organization_id
  end
end
