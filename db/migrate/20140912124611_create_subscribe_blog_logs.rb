class CreateSubscribeBlogLogs < ActiveRecord::Migration
  def change
    create_table :subscribe_blog_logs do |t|
      t.integer :contact_id
      t.string :contact_email
      t.text :blog_title
      t.text :blog_content
      t.string :status
	  t.string :error_message

      t.timestamps
    end
  end
end
