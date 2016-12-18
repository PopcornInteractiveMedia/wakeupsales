class CreateNoteAttachments < ActiveRecord::Migration
  def change
    create_table :note_attachments do |t|
      t.references :note
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.timestamps
    end
    add_index :note_attachments, :note_id
  end
end
