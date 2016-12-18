class AddClosedByToDeals < ActiveRecord::Migration
  def change
   add_column :deals, :closed_by, :integer,  :null => true
  end
end
