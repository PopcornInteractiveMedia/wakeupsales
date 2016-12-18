class CreatePaymentInfos < ActiveRecord::Migration
  def change
    create_table :payment_infos do |t|
      t.references :organization
      t.string :transaction_id
      t.float :amount
      t.datetime :transaction_date
      t.string :last4_digit
      t.string :customer_id
      t.string :card_holder_name
      t.string :street
      t.string :city
      t.string :country
      t.string :zipcode
      t.string :payment_token

      t.timestamps
    end
    add_index :payment_infos, :organization_id
  end
end
