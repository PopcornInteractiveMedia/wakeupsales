class AddSourceIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :source_id, :integer
  end
end
