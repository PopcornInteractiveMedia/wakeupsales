class CreateTempContacts < ActiveRecord::Migration
  def change
    create_table :temp_contacts do |t|
      t.integer :import_by
      t.string :domain
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :gender
      t.string :birthday
      t.string :relation
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :region
      t.string :country
      t.string :postcode
      t.string :phone_number
      t.string :profile_picture
      t.string :updated
      
      t.timestamps
    end
  end
end
