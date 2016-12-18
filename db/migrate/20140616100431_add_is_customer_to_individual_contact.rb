class AddIsCustomerToIndividualContact < ActiveRecord::Migration
  def change
    add_column :individual_contacts, :is_customer, :boolean, :null => false, :default => false
  end
end
