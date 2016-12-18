class CreateContactUsInfos < ActiveRecord::Migration
  def change
    create_table :contact_us_infos do |t|
      t.string :name
      t.text :comment
      t.string :phone
      t.references :contact_us

      t.timestamps
    end
    add_index :contact_us_infos, :contact_us_id
  end
end
