class AddIsOpportunityToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :is_opportunity, :boolean, :null => false, :default => false
  end
end
