class AddTimeZoneToCompanyContacts < ActiveRecord::Migration
  def change
   add_column :company_contacts, :time_zone, :string
  end
end
