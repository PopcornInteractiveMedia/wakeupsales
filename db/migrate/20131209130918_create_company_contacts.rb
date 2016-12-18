class CreateCompanyContacts < ActiveRecord::Migration
  def change
    create_table :company_contacts do |t|
      t.integer :organization_id
      t.string  :name
      t.references :company_strength
      t.string  :email
      t.string  :messanger_type
      t.string :messanger_id
      t.string  :website
      t.string  :linkedin_url
      t.string  :facebook_url
      t.string  :twitter_url
      t.integer :created_by
      t.boolean :is_public, null: false, default: true
      t.boolean :is_active, null: false, default: true
      t.integer :contact_ref_id
      t.timestamps
    end
  end
end
