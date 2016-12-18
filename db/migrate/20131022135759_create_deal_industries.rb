class CreateDealIndustries < ActiveRecord::Migration
  def change
    create_table :deal_industries do |t|
      t.references :organization
      t.references :deal
      t.references :industry

      t.timestamps
    end
    add_index :deal_industries, :organization_id
    add_index :deal_industries, :deal_id
    add_index :deal_industries, :industry_id
  end
end
