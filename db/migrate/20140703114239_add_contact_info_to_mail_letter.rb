class AddContactInfoToMailLetter < ActiveRecord::Migration
  def change
    add_column :mail_letters, :contact_info, :text
  end
end
