class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :organization
      t.string :name

      t.timestamps
    end
    add_index :roles, :organization_id
  end
end
