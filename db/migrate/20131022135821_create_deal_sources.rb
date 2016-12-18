class CreateDealSources < ActiveRecord::Migration
  def change
    create_table :deal_sources do |t|
      t.references :organization
      t.references :deal
      t.references :source

      t.timestamps
    end
    add_index :deal_sources, :organization_id
    add_index :deal_sources, :deal_id
    add_index :deal_sources, :source_id
  end
end
