class AddIndividualContactIdToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :individual_contact_id, :integer
  end
end
