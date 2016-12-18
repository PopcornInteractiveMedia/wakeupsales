class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :ccode
      t.string :name
      t.string :isd_code
      t.string :flag
    end
  end
end
