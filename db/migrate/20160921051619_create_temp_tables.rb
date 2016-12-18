class CreateTempTables < ActiveRecord::Migration
  def change
    create_table :temp_tables do |t|
      t.string :name
      t.string :email
      t.integer :phone
      t.string :title
      t.string :company_name
      t.string :web_site
      t.text :address
      t.string :ref_site

      t.timestamps
    end
  end
end
