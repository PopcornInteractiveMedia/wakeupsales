class AddDurationToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :duration, :string
    add_column :deals, :billing_type, :string
  end
end
