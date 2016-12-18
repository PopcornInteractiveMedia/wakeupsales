class AddVisitedToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :visited, :string
  end
end
