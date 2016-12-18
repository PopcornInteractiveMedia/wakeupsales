class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :organization
      t.text :notes
      t.string :file_description
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.string :notable_type
      t.integer :notable_id

      t.timestamps
    end
    add_index :notes, :organization_id
  end
end
