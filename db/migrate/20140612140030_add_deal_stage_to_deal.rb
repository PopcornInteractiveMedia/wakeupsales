class AddDealStageToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :stage_move_date, :timestamp
  end
end
