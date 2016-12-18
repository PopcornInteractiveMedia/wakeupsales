class AddPriorityLabelToUser < ActiveRecord::Migration
  def change
    add_column :users, :priority_label, :integer, :default => 0, :null => false
  end
end
