class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :organization
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :imagable_type
      t.integer :imagable_id

      t.timestamps
    end
    add_index :images, :organization_id
  end
end
