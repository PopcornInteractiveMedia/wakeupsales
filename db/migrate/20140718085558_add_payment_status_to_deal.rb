class AddPaymentStatusToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :payment_status, :string, :default => "Not done"
  end
end
