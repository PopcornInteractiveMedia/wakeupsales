class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.references :organization
      t.string :name
      t.references :company_strength
      t.string :contact_type
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :website
      t.string :messanger_type
      t.string :messanger_id
      t.string :linkedin_url
      t.string :facebook_url
      t.string :twitter_url
      t.boolean :is_public
      t.integer :created_by

      t.timestamps
    end
    add_index :contacts, :organization_id
    add_index :contacts, :company_strength_id
  end
end
