class AddIsAvailableToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :is_available, :boolean, default: false
  end
end
