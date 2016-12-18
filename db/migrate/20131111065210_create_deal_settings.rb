class CreateDealSettings < ActiveRecord::Migration
  def change
    create_table :deal_settings do |t|
      t.references :organization
      t.references :user
      t.string :tabs

      t.timestamps
    end
    add_index :deal_settings, :organization_id
    add_index :deal_settings, :user_id
  end
end
