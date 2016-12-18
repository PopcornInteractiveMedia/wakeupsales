class AddLocationByApiToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :location_by_api, :text
	change_column :deals, :visited, :text
  end
end
