class AddNewColumnToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :is_csv, :boolean, :default => false
    add_column :deals, :is_mail_sent, :boolean, :default => true
  end
end
