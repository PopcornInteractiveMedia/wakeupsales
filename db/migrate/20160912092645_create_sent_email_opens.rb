class CreateSentEmailOpens < ActiveRecord::Migration
  def change
    create_table :sent_email_opens do |t|
        t.string   :name
        t.string   :email
        t.string   :ip_address
        t.string   :opened
        t.integer  :activity_id
        t.timestamps
    end
  end
end
