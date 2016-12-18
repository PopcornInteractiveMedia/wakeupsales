class CreateTempLeads < ActiveRecord::Migration
  def change
    create_table :temp_leads do |t|
      t.integer :user_id
      t.text :title
      t.string :priority
      t.string :company_name
      t.string :company_size
      t.string :website
      t.string :contact_name
      t.string :designation
      t.string :phone
      t.string :extension
      t.string :mobile
      t.string :email
      t.string :technology
      t.text :source
      t.string :location
      t.string :country
      t.string :industry
      t.text :comments
      t.datetime :created_dt
      t.text :description      
      t.string :assigned_to
      t.string :facebook_url
      t.string :linkedin_url
      t.string :twitter_url
      
      t.timestamps
    end
  end
end




