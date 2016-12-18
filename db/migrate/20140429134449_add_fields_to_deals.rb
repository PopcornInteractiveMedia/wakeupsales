class AddFieldsToDeals < ActiveRecord::Migration
  def change
   add_column :deals, :is_remote, :boolean, default: false
   add_column :deals, :app_type, :string
  end
end
