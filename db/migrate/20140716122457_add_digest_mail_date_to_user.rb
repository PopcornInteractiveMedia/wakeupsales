class AddDigestMailDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :digest_mail_date, :string
  end
end
