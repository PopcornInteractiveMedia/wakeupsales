class ModifySchemaforIndividualContact < ActiveRecord::Migration
  def change
    add_column :individual_contacts, :website, :string
    add_column :individual_contacts, :city, :string
    add_column :individual_contacts, :state, :string
    add_column :individual_contacts, :country, :string
    add_column :individual_contacts, :company_name, :string
    add_column :individual_contacts, :work_phone, :string
    add_column :individual_contacts, :description, :text
  end
end
