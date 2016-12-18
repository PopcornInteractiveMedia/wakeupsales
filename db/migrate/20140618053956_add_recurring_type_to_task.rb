class AddRecurringTypeToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :recurring_type, :string, null: false, default: "none"
    add_column :tasks, :rec_end_date, :datetime
    add_column :tasks, :parent_id, :integer
    execute <<-SQL
      update tasks set parent_id=id;
    SQL
  end
end

