class CreateSalesCycles < ActiveRecord::Migration
  def change
    create_table :sales_cycles do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :year
      t.integer :quarter
      t.integer :average
      t.integer :shortest
      t.integer :longest

      t.timestamps
    end
  end
end
