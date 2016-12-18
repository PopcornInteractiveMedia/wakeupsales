class AddCountryIdToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :country_id, :integer
  end
end
