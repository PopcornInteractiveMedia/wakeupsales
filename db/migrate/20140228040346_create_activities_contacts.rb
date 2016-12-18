class CreateActivitiesContacts < ActiveRecord::Migration
  def change
    create_table :activities_contacts do |t|
      t.integer :organization_id
      t.integer :activity_id
      t.string :contactable_type
      t.integer :contactable_id

      t.timestamps
    end
  end
end
