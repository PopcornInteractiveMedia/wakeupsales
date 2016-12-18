class CreateBetaAccounts < ActiveRecord::Migration
  def change
    create_table :beta_accounts do |t|
      t.string :email
      t.text :invitation_token
      t.integer :invited_by
      t.boolean :is_verified, :default => false
      t.boolean :is_approved, :default => false
      t.boolean :is_registered, :default => false
      t.boolean :is_siteadmin_invited, :default => false

      t.timestamps
    end
  end
end
