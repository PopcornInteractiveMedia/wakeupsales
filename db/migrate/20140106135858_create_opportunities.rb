class CreateOpportunities < ActiveRecord::Migration
  def change
    create_table :opportunities do |t|
      t.integer :organization_id
      t.integer :user_id
      t.integer :year
      t.integer :quarter
      t.integer :total_deals
      t.integer :won_deals
      t.float :win

      t.timestamps
    end
  end
end
