class AddReferrerToDeal < ActiveRecord::Migration
  def change
    add_column :deals, :referrer, :string
  end
end
