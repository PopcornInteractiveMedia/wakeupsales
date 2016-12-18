class AddFieldsToTempTable < ActiveRecord::Migration
  def change
    add_column :temp_tables, :city, :string
    add_column :temp_tables, :state, :string
    add_column :temp_tables, :zipcode, :string
    add_column :temp_tables, :country, :string
  end
end
