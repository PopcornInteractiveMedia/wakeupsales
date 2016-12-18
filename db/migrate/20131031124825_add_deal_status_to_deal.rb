class AddDealStatusToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :deal_status_id, :integer
  end
end
