class AddIndivisualContactIdToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :indivisual_contact_id, :integer
  end
end
