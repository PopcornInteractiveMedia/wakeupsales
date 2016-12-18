class AddSourceIdIndexingToActivity < ActiveRecord::Migration
  def change
    add_index(:activities, :source_id)
  end
end
