class CreateDealLabels < ActiveRecord::Migration
  def change
    create_table :deal_labels do |t|
      t.references :organization
      t.references :deal
      t.references :user_label

      t.timestamps
    end
    add_index :deal_labels, :organization_id
    add_index :deal_labels, :deal_id
    add_index :deal_labels, :user_label_id
  end
end
