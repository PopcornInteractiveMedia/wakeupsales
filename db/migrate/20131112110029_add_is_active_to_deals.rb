class AddIsActiveToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :is_active, :boolean
    add_column :deals, :is_current, :boolean
    ActiveRecord::Base.connection.execute("UPDATE deals set is_active = true;")
    ActiveRecord::Base.connection.execute("UPDATE deals set is_current = false;")
    
  end
end
