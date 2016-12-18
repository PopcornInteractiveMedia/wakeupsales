class CreateDownloadUsers < ActiveRecord::Migration
  def change
    create_table :download_users do |t|
      t.string :name
      t.string :email
      t.string :ip_address

      t.timestamps
    end
  end
end
