class CreateDealMoves < ActiveRecord::Migration
  def change
    create_table :deal_moves do |t|
      t.references :organization
      t.references :deal
      t.references :deal_status
      t.references :user

      t.timestamps
    end
    add_index :deal_moves, :organization_id
    add_index :deal_moves, :deal_id
    add_index :deal_moves, :deal_status_id
    add_index :deal_moves, :user_id
  end
end
