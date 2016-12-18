class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :user_id
	  t.integer :organization_id
      t.boolean :weekly_digest, null: false, :default => true
      t.references :user

      t.timestamps
    end
    execute <<-SQL
     INSERT INTO user_preferences (user_id,organization_id) select id,organization_id from users;     
    SQL
    add_index :user_preferences, :user_id
  end
end
