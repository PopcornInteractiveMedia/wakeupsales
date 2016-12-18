class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :organization
      t.references :role
      t.references :user

      t.timestamps
    end
    add_index :user_roles, :organization_id
    add_index :user_roles, :role_id
  end
end
