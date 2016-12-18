class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.references :organization
      t.string :name

      t.timestamps
    end
    add_index :sources, :organization_id
  end
end
