class CreateIndividualContacts < ActiveRecord::Migration
  def change
    create_table :individual_contacts do |t|
      t.integer :organization_id
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.string  :position
      t.string  :messanger_type
      t.string :messanger_id
      t.string  :linkedin_url
      t.string  :facebook_url
      t.string  :twitter_url
      t.references :company_contact
      t.integer :created_by
      t.boolean :is_public, null: false, default: true
      t.boolean :is_active, null: false, default: true
      t.integer :contact_ref_id
      t.timestamps
    end
  end
end
