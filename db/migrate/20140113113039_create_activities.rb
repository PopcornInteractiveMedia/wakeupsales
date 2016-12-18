class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :organization
      t.string :activity_type
      t.integer :activity_id
      t.integer :activity_user_id
	  t.string :activity_status
      t.string :activity_desc
      t.datetime :activity_date
	  t.boolean :is_public, :null=>false, :default=> true

      t.timestamps
    end
	add_index :activities, :activity_user_id
	add_index  :activities, :organization_id
	add_index  :activities, :activity_date
  end
end
