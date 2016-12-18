class CreateMailLetters < ActiveRecord::Migration
  def change
    create_table :mail_letters do |t|
      t.references :organization
      t.string :mailable_type
      t.integer :mailable_id
      t.string :mailto
      t.string :subject
      t.text :description
      t.integer :mail_by
      t.string :mail_cc
      t.string :mail_bcc

      t.timestamps
    end
    add_index :mail_letters, :organization_id
  end
end
