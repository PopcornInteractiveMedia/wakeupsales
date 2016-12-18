class AddDefaultValueToIsPublic < ActiveRecord::Migration
  def change
    change_column :deals, :is_public, :boolean, default: true
  end
end
