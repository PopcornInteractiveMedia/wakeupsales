class AddSubscribeBlogMailToIndividualContact < ActiveRecord::Migration
  def change
    add_column :individual_contacts, :subscribe_blog_mail, :boolean, :default => true, :null => false
	add_column :individual_contacts, :subscribe_blog_date, :datetime
  end
end
