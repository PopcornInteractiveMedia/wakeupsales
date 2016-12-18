class AddPriorityTokenToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :hot_lead_token, :text
    add_column :deals, :token_expiry_time, :datetime
    add_column :deals, :next_priority_id, :integer
    add_column :deals, :assignee_id, :integer
  end
end
