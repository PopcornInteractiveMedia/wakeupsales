class AddTimeZoneToIndividualContacts < ActiveRecord::Migration
  def change
   add_column :individual_contacts, :time_zone, :string
  end
end
