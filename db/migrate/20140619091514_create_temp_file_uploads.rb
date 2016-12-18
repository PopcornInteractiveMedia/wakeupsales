class CreateTempFileUploads < ActiveRecord::Migration
  def change
    create_table :temp_file_uploads do |t|
      t.integer :user_id
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.timestamps
    end
  end
end
