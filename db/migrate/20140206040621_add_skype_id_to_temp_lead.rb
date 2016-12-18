class AddSkypeIdToTempLead < ActiveRecord::Migration
  def change
    add_column :temp_leads, :skype_id, :string
  end
end
