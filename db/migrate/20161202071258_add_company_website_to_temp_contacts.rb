class AddCompanyWebsiteToTempContacts < ActiveRecord::Migration
  def change
    add_column :temp_contacts, :company_name, :string
    add_column :temp_contacts, :website, :string
  end
end
