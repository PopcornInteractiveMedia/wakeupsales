class RenameTitleToEmailFromComment < ActiveRecord::Migration
  def change
  	rename_column :comments, :title, :email
  	add_column :report_a_bugs, :ip_address, :string
  	add_column :report_a_bugs, :country, :string
  end
end
