class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :email
      t.string :website
      t.integer :total_users
      t.integer :size_id
      t.boolean :is_premium
      t.boolean :is_active
      t.datetime :deleted_at
      t.integer :beta_account_id
      
      t.timestamps
    end
  end
end
