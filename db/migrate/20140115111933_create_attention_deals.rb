class CreateAttentionDeals < ActiveRecord::Migration
  def change
    create_table :attention_deals do |t|
      t.integer :organization_id
      t.integer :user_id
      t.text  :deal_ids
      t.integer :deal_count
      t.timestamps
    end
  end
end
