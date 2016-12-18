class AddLastActivityDateToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :last_activity_date, :datetime
  end
end
