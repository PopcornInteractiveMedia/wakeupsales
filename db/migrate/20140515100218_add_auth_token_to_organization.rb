class AddAuthTokenToOrganization < ActiveRecord::Migration
  def change
  add_column :organizations, :auth_token, :string
 
  end
end
