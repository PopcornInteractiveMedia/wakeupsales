class AddFieldToNotes < ActiveRecord::Migration
  def change
  add_column :notes, :is_public, :boolean, default: false
  end
end
