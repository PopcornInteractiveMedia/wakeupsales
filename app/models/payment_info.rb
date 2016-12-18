class PaymentInfo < ActiveRecord::Base
  belongs_to :organization
  attr_accessible :amount, :card_holder_name, :city, :country, :customer_id, :last4_digit, :payment_token, :street, :transaction_date, :transaction_id, :zipcode
end
