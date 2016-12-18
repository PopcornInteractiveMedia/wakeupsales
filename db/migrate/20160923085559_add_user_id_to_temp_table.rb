class AddUserIdToTempTable < ActiveRecord::Migration
  def change
    add_column :temp_tables, :user_id, :integer
  end
end
