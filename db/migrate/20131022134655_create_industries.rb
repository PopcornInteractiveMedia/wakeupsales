class CreateIndustries < ActiveRecord::Migration
  def change
    create_table :industries do |t|
      t.references :organization
      t.string :name

      t.timestamps
    end
    add_index :industries, :organization_id
  end
end
