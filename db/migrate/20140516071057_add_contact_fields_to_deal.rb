class AddContactFieldsToDeal < ActiveRecord::Migration
  def change
   #add_column :deals, :contact_name, :string
   #add_column :deals, :email, :string
   #add_column :deals, :degn_company, :string
   add_column :deals, :contact_info, :text
   #add_column :deals, :contact_id, :integer
  end
end
